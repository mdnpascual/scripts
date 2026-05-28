# INSTALLATION

pip install pymupdf pillow requests

# USAGE

# Process with default settings (5 pages per batch)
python pdf_transcriber.py annual_report.pdf

# Custom batch size (10 pages at a time)
python pdf_transcriber.py annual_report.pdf -b 10

# Custom output file
python pdf_transcriber.py annual_report.pdf -o knowledge_base.md