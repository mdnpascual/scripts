// Unminified Source code bookmarklet to sort barter.vg bundle tables
// Sorting rules:
// 1) Sort only within tiers
// 2) Put owned games in last
// 3) Put unowned games by rating

javascript:(function(){
    // Get the table and all rows
    const table = document.querySelector('.collection');
    const tbody = table.querySelector('tbody');
    const allRows = Array.from(tbody.querySelectorAll(':scope > tr'));
    
    // Split rows into tiers
    const tiers = [];
    let currentTier = [];
    let currentTierHeader = null;
    
    // First, identify tier boundaries and group rows
    let i = 0;
    while (i < allRows.length) {
        const row = allRows[i];
        
        // Check if this row is a tier header
        if (row.querySelector('td.tierLine')) {
            // If we have rows in the current tier, save them
            if (currentTier.length > 0) {
                tiers.push({
                    header: currentTierHeader,
                    rows: currentTier
                });
            }
            
            // Start a new tier
            currentTierHeader = row;
            currentTier = [];
            i++;
            continue;
        }
        
        // Handle normal game entries (main row + bargraph row)
        if (row.querySelector('input[type="checkbox"]')) {
            // This is a main entry row
            const gameEntry = {
                mainRow: row,
                bargraphRow: allRows[i+1],
                packageRows: []
            };
            
            // Skip the bargraph row
            i += 2;
            
            // Check if the next row is a package entry
            if (i < allRows.length && allRows[i].querySelector('td.included')) {
                // This is a package entry
                gameEntry.packageRows.push(allRows[i]);
                
                // Skip to after the package rows
                i++;
                // Continue collecting package rows until we hit a new main entry or tier header
                while (i < allRows.length && 
                      !allRows[i].querySelector('input[type="checkbox"]') && 
                      !allRows[i].querySelector('td.tierLine')) {
                    gameEntry.packageRows.push(allRows[i]);
                    i++;
                }
            }
            
            // Add this game entry to the current tier
            currentTier.push(gameEntry);
        } else {
            // Skip any other rows
            i++;
        }
    }
    
    // Add the last tier if it has rows
    if (currentTier.length > 0) {
        tiers.push({
            header: currentTierHeader,
            rows: currentTier
        });
    }
    console.log("tiers", tiers);
    // Process each tier separately - sort game entries within tiers
    for (let t = 0; t < tiers.length; t++) {
        const tier = tiers[t];
        
        // Sort game entries within this tier
        tier.rows.sort((a, b) => {
            // Check if they are in library
            const aInLibrary = a.mainRow.querySelector('.libr') !== null;
            const bInLibrary = b.mainRow.querySelector('.libr') !== null;
            
            // Sort non-library items first
            if (aInLibrary && !bInLibrary) return 1;
            if (!aInLibrary && bInLibrary) return -1;
            
            // For items with the same library status, sort by review score
            const aReviewCell = a.mainRow.querySelector('td:nth-child(6)');
            const bReviewCell = b.mainRow.querySelector('td:nth-child(6)');
            
            if (!aReviewCell || !bReviewCell) return 0;
            
            // Extract percentage from review text
            const aReviewMatch = aReviewCell.innerText.match(/(\d+)%/);
            const bReviewMatch = bReviewCell.innerText.match(/(\d+)%/);
            
            const aReviewScore = aReviewMatch ? parseInt(aReviewMatch[1], 10) : 0;
            const bReviewScore = bReviewMatch ? parseInt(bReviewMatch[1], 10) : 0;
            
            // Sort by review score (higher first)
            if (aReviewScore !== bReviewScore) return bReviewScore - aReviewScore;
            
            // If review scores are equal, sort by review count
            const aCountMatch = aReviewCell.innerText.match(/(\d+)\s*$/);
            const bCountMatch = bReviewCell.innerText.match(/(\d+)\s*$/);
            
            const aCount = aCountMatch ? parseInt(aCountMatch[1], 10) : 0;
            const bCount = bCountMatch ? parseInt(bCountMatch[1], 10) : 0;
            
            return bCount - aCount;
        });
    }
    
    // Rebuild the tbody
    tbody.innerHTML = '';
    
    // Add the sorted tiers back to the tbody
    for (const tier of tiers) {
        // Add the tier header
        if (tier.header) {
            tbody.appendChild(tier.header);
        }
        
        // Add each game entry with its associated rows
        for (const gameEntry of tier.rows) {
            tbody.appendChild(gameEntry.mainRow);
            tbody.appendChild(gameEntry.bargraphRow);
            
            // Add any package rows
            for (const packageRow of gameEntry.packageRows) {
                tbody.appendChild(packageRow);
            }
        }
    }
})();
