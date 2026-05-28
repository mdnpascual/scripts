#!/usr/bin/env python3
"""
PDF Annual Report Transcriber for Local LLM (LM Studio)
Processes PDFs in chunks, transcribing text and describing graphics
for knowledge base compression.
"""

import os
import sys
import json
import base64
import argparse
import time
from pathlib import Path
from typing import Optional
import requests

# PDF processing
try:
    import fitz  # PyMuPDF
except ImportError:
    print("Please install PyMuPDF: pip install pymupdf")
    sys.exit(1)

try:
    from PIL import Image
except ImportError:
    print("Please install Pillow: pip install pillow")
    sys.exit(1)

import io


class PDFTranscriber:
    """Transcribes PDF documents using a local LLM via LM Studio."""

    def __init__(
        self,
        lm_studio_url: str = "http://localhost:1234/v1",
        model_name: str = "gemma-4-31b",
        pages_per_batch: int = 5,
        output_file: str = "transcription.md",
        image_detail: str = "high",
        max_tokens: int = 4096,
        temperature: float = 0.3,
    ):
        self.lm_studio_url = lm_studio_url.rstrip("/")
        self.model_name = model_name
        self.pages_per_batch = pages_per_batch
        self.output_file = output_file
        self.image_detail = image_detail
        self.max_tokens = max_tokens
        self.temperature = temperature

        # Verify LM Studio connection
        self._verify_connection()

    def _verify_connection(self):
        """Verify LM Studio is running and accessible."""
        try:
            response = requests.get(f"{self.lm_studio_url}/models", timeout=10)
            if response.status_code == 200:
                print(f"✓ Connected to LM Studio at {self.lm_studio_url}")
                models = response.json()
                print(f"  Available models: {[m.get('id', 'unknown') for m in models.get('data', [])]}")
            else:
                print(f"⚠ LM Studio responded with status {response.status_code}")
        except requests.exceptions.ConnectionError:
            print(f"✗ Cannot connect to LM Studio at {self.lm_studio_url}")
            print("  Make sure LM Studio is running with the local server enabled.")
            sys.exit(1)

    def _encode_image_to_base64(self, image_bytes: bytes) -> str:
        """Encode image bytes to base64 string."""
        return base64.b64encode(image_bytes).decode("utf-8")

    def _page_to_image(self, page: fitz.Page, dpi: int = 150) -> bytes:
        """Convert a PDF page to PNG image bytes."""
        mat = fitz.Matrix(dpi / 72, dpi / 72)
        pix = page.get_pixmap(matrix=mat)
        return pix.tobytes("png")

    def _extract_page_text(self, page: fitz.Page) -> str:
        """Extract raw text from a PDF page."""
        return page.get_text("text")

    def _extract_images_from_page(self, page: fitz.Page, doc: fitz.Document) -> list[bytes]:
        """Extract embedded images from a PDF page."""
        images = []
        image_list = page.get_images(full=True)

        for img_index, img_info in enumerate(image_list):
            xref = img_info[0]
            try:
                base_image = doc.extract_image(xref)
                image_bytes = base_image["image"]

                # Open image with Pillow
                img = Image.open(io.BytesIO(image_bytes))

                # Convert CMYK or other modes to RGB
                if img.mode == "CMYK":
                    img = img.convert("RGB")
                elif img.mode == "P":  # Palette mode
                    img = img.convert("RGBA")
                elif img.mode == "LA":  # Grayscale with alpha
                    img = img.convert("RGBA")
                elif img.mode == "L":  # Grayscale
                    img = img.convert("RGB")
                elif img.mode not in ("RGB", "RGBA"):
                    img = img.convert("RGB")

                # Save as PNG
                png_buffer = io.BytesIO()
                img.save(png_buffer, format="PNG")
                images.append(png_buffer.getvalue())

            except Exception as e:
                print(f"    Warning: Could not extract image {img_index}: {e}")

        return images

    def _call_llm(self, messages: list[dict], include_images: bool = False) -> str:
        """Call the LM Studio API with the given messages."""
        payload = {
            "model": self.model_name,
            "messages": messages,
            "max_tokens": self.max_tokens,
            "temperature": self.temperature,
            "stream": False,
        }

        try:
            response = requests.post(
                f"{self.lm_studio_url}/chat/completions",
                headers={"Content-Type": "application/json"},
                json=payload,
                timeout=300,  # 5 minute timeout for long responses
            )

            if response.status_code == 200:
                result = response.json()
                return result["choices"][0]["message"]["content"]
            else:
                print(f"    Error: LLM returned status {response.status_code}")
                print(f"    Response: {response.text[:500]}")
                return ""
        except requests.exceptions.Timeout:
            print("    Error: LLM request timed out")
            return ""
        except Exception as e:
            print(f"    Error calling LLM: {e}")
            return ""

    def _call_llm_with_vision(self, prompt: str, images: list[bytes]) -> str:
        """Call LLM with vision capabilities for image description."""
        content = [{"type": "text", "text": prompt}]

        for img_bytes in images:
            base64_img = self._encode_image_to_base64(img_bytes)
            content.append({
                "type": "image_url",
                "image_url": {
                    "url": f"data:image/png;base64,{base64_img}",
                    "detail": self.image_detail
                }
            })

        messages = [{"role": "user", "content": content}]
        return self._call_llm(messages, include_images=True)

    def _process_page_batch(
        self,
        doc: fitz.Document,
        start_page: int,
        end_page: int,
        use_vision: bool = True
    ) -> str:
        """Process a batch of pages and return transcription."""

        batch_content = []

        for page_num in range(start_page, min(end_page, len(doc))):
            page = doc[page_num]
            print(f"    Processing page {page_num + 1}...")

            # Extract text
            raw_text = self._extract_page_text(page)

            # Extract images if vision is enabled
            images = []
            if use_vision:
                images = self._extract_images_from_page(page, doc)

            page_content = f"\n\n{'='*60}\n## PAGE {page_num + 1}\n{'='*60}\n\n"

            # If we have images and vision capability, use vision model
            if images and use_vision:
                # Render full page as image for context
                page_image = self._page_to_image(page)

                vision_prompt = f"""Analyze this PDF page (Page {page_num + 1}) from an annual report.

Your task is to create a comprehensive text transcription that captures ALL information, including:

1. **Text Content**: Transcribe all visible text, maintaining logical structure and hierarchy.

2. **Tables**: Convert any tables to markdown table format, preserving all data.

3. **Charts/Graphs**: Describe in detail:
   - Type of chart (bar, line, pie, etc.)
   - What data it represents
   - Key values, trends, and data points
   - Axis labels and legends
   - Any notable insights the visual conveys

4. **Diagrams/Infographics**: Describe the visual structure and all information conveyed.

5. **Images**: Describe any photographs or illustrations and their relevance.

Raw text extracted from this page (may be incomplete or poorly formatted):
---
{raw_text[:2000] if raw_text else "[No text extracted]"}
---

Provide a clean, well-structured markdown transcription that captures ALL information from this page.
Someone reading your transcription should understand everything on this page without seeing the original."""

                page_transcription = self._call_llm_with_vision(vision_prompt, [page_image])

                if page_transcription:
                    page_content += page_transcription
                else:
                    # Fallback to text-only
                    page_content += self._process_text_only(raw_text, page_num)
            else:
                # Text-only processing
                page_content += self._process_text_only(raw_text, page_num)

            batch_content.append(page_content)

            # Small delay to avoid overwhelming the local model
            time.sleep(0.5)

        return "\n".join(batch_content)

    def _process_text_only(self, raw_text: str, page_num: int) -> str:
        """Process page with text-only LLM (no vision)."""
        if not raw_text.strip():
            return "*[This page appears to be blank or contains only images that could not be processed]*\n"

        prompt = f"""Clean up and structure the following raw text extracted from page {page_num + 1} of an annual report.

Tasks:
1. Fix any OCR errors or formatting issues
2. Restore proper paragraph structure
3. Convert any detected table data into markdown tables
4. Maintain headers and hierarchy
5. Note if there appear to be references to charts/figures that couldn't be extracted

Raw text:
---
{raw_text}
---

Provide a clean, well-structured markdown version:"""

        messages = [{"role": "user", "content": prompt}]
        result = self._call_llm(messages)

        return result if result else raw_text

    def _load_existing_transcription(self) -> str:
        """Load existing transcription file if it exists."""
        if os.path.exists(self.output_file):
            with open(self.output_file, "r", encoding="utf-8") as f:
                return f.read()
        return ""

    def _save_transcription(self, content: str):
        """Save transcription to file."""
        with open(self.output_file, "w", encoding="utf-8") as f:
            f.write(content)

    def _get_progress_file(self) -> str:
        """Get the progress tracking file path."""
        return f"{self.output_file}.progress"

    def _load_progress(self) -> int:
        """Load the last processed page number."""
        progress_file = self._get_progress_file()
        if os.path.exists(progress_file):
            with open(progress_file, "r") as f:
                return int(f.read().strip())
        return 0

    def _save_progress(self, last_page: int):
        """Save progress to file."""
        progress_file = self._get_progress_file()
        with open(progress_file, "w") as f:
            f.write(str(last_page))

    def _clear_progress(self):
        """Clear progress file after completion."""
        progress_file = self._get_progress_file()
        if os.path.exists(progress_file):
            os.remove(progress_file)

    def transcribe(
        self,
        pdf_path: str,
        use_vision: bool = True,
        resume: bool = True
    ) -> str:
        """
        Transcribe an entire PDF document.

        Args:
            pdf_path: Path to the PDF file
            use_vision: Whether to use vision capabilities for images/charts
            resume: Whether to resume from last progress

        Returns:
            Path to the output transcription file
        """
        pdf_path = Path(pdf_path)
        if not pdf_path.exists():
            raise FileNotFoundError(f"PDF not found: {pdf_path}")

        print(f"\n{'='*60}")
        print(f"PDF ANNUAL REPORT TRANSCRIBER")
        print(f"{'='*60}")
        print(f"Input PDF: {pdf_path}")
        print(f"Output file: {self.output_file}")
        print(f"Pages per batch: {self.pages_per_batch}")
        print(f"Vision enabled: {use_vision}")
        print(f"Model: {self.model_name}")
        print(f"{'='*60}\n")

        # Open PDF
        doc = fitz.open(pdf_path)
        total_pages = len(doc)
        print(f"Total pages in PDF: {total_pages}")

        # Check for resume
        start_page = 0
        existing_content = ""

        if resume:
            start_page = self._load_progress()
            if start_page > 0:
                print(f"Resuming from page {start_page + 1}")
                existing_content = self._load_existing_transcription()

        if start_page == 0:
            # Create header for new transcription
            existing_content = f"""# Transcription: {pdf_path.name}

**Source Document**: {pdf_path.name}
**Total Pages**: {total_pages}
**Transcription Date**: {time.strftime("%Y-%m-%d %H:%M:%S")}
**Model Used**: {self.model_name}

---

"""
            self._save_transcription(existing_content)

        # Process in batches
        current_page = start_page

        while current_page < total_pages:
            batch_end = min(current_page + self.pages_per_batch, total_pages)

            print(f"\n[Batch] Processing pages {current_page + 1} to {batch_end} of {total_pages}")
            print(f"        Progress: {current_page}/{total_pages} ({100*current_page/total_pages:.1f}%)")

            # Process batch
            batch_content = self._process_page_batch(
                doc, current_page, batch_end, use_vision
            )

            # Load current content and append
            existing_content = self._load_existing_transcription()
            existing_content += batch_content

            # Save updated transcription
            self._save_transcription(existing_content)

            # Save progress
            self._save_progress(batch_end)

            print(f"        ✓ Batch complete. Saved to {self.output_file}")

            current_page = batch_end

        # Cleanup
        doc.close()
        self._clear_progress()

        # Add footer
        existing_content = self._load_existing_transcription()
        existing_content += f"""

---

**Transcription Complete**
**Pages Processed**: {total_pages}
**Completion Time**: {time.strftime("%Y-%m-%d %H:%M:%S")}
"""
        self._save_transcription(existing_content)

        print(f"\n{'='*60}")
        print(f"✓ TRANSCRIPTION COMPLETE")
        print(f"  Output saved to: {self.output_file}")
        print(f"  Total pages processed: {total_pages}")
        print(f"{'='*60}\n")

        return self.output_file


def main():
    parser = argparse.ArgumentParser(
        description="Transcribe PDF annual reports using local LLM (LM Studio)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Basic usage with defaults
  python pdf_transcriber.py report.pdf

  # Custom batch size and output
  python pdf_transcriber.py report.pdf -b 10 -o my_transcription.md

  # Text-only mode (no vision/image processing)
  python pdf_transcriber.py report.pdf --no-vision

  # Custom LM Studio URL and model
  python pdf_transcriber.py report.pdf --url http://localhost:1234/v1 --model gemma-4-31b

  # Start fresh (ignore previous progress)
  python pdf_transcriber.py report.pdf --no-resume
        """
    )

    parser.add_argument("pdf_path", help="Path to the PDF file to transcribe")

    parser.add_argument(
        "-b", "--batch-size",
        type=int,
        default=5,
        help="Number of pages to process per batch (default: 5)"
    )

    parser.add_argument(
        "-o", "--output",
        type=str,
        default=None,
        help="Output file path (default: <pdf_name>_transcription.md)"
    )

    parser.add_argument(
        "--url",
        type=str,
        default="http://localhost:1234/v1",
        help="LM Studio API URL (default: http://localhost:1234/v1)"
    )

    parser.add_argument(
        "--model",
        type=str,
        default="gemma-4-31b",
        help="Model name to use (default: gemma-4-31b)"
    )

    parser.add_argument(
        "--no-vision",
        action="store_true",
        help="Disable vision/image processing (text-only mode)"
    )

    parser.add_argument(
        "--no-resume",
        action="store_true",
        help="Start fresh, ignoring any previous progress"
    )

    parser.add_argument(
        "--max-tokens",
        type=int,
        default=4096,
        help="Maximum tokens for LLM response (default: 4096)"
    )

    parser.add_argument(
        "--temperature",
        type=float,
        default=0.3,
        help="LLM temperature (default: 0.3)"
    )

    args = parser.parse_args()

    # Set default output filename based on input PDF
    if args.output is None:
        pdf_name = Path(args.pdf_path).stem
        args.output = f"{pdf_name}_transcription.md"

    # Create transcriber
    transcriber = PDFTranscriber(
        lm_studio_url=args.url,
        model_name=args.model,
        pages_per_batch=args.batch_size,
        output_file=args.output,
        max_tokens=args.max_tokens,
        temperature=args.temperature,
    )

    # Run transcription
    try:
        output_path = transcriber.transcribe(
            pdf_path=args.pdf_path,
            use_vision=not args.no_vision,
            resume=not args.no_resume,
        )
        print(f"Transcription saved to: {output_path}")
    except KeyboardInterrupt:
        print("\n\nTranscription interrupted. Progress has been saved.")
        print("Run the same command again to resume.")
        sys.exit(0)
    except Exception as e:
        print(f"\nError: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
