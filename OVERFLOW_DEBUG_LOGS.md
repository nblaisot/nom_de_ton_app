# Overflow Debugging - Enhanced Logging

## Changes Made

### 1. Increased Safety Margin (line_metrics_pagination_engine.dart)
- Changed from 50px to **100px** safety margin
- This matches the cosmos_epub approach which uses 120-150px
- The safety margin is subtracted from the available page height during pagination

### 2. Enhanced Pagination Logging
Added comprehensive debug logging in `line_metrics_pagination_engine.dart`:

**Initial Summary:**
```
┌─────────────────────────────────────────────────────
│ PAGINATION ENGINE: Building pages
│ Total blocks to paginate: X
│ Max dimensions: Ww x Hh (with 100px safety margin)
└─────────────────────────────────────────────────────
```

**For Each Text Block:**
- Block text length and total lines
- Spacing before/after
- Max page height and width

**For Each Line:**
- Line height, cumulative height, and total height with line
- Helps identify exactly when a page break decision is made

**Page Break Events:**
```
>>> PAGE BREAK <<<
Created page N: X chars
  Final page height: Y (overflow prevented: Z)
  Page text preview: "..."
```

**Final Summary:**
```
┌─────────────────────────────────────────────────────
│ PAGINATION ENGINE: Complete
│ Total pages created: N
│ Total characters: X
└─────────────────────────────────────────────────────
```

### 3. Enhanced Rendering Logging
Added detailed logging in `reader_screen.dart` (_PageContentView):

**For Each Page Rendered:**
```
=== Rendering Page ===
Max dimensions: Ww x Hh
Number of blocks: N
```

**For Each Block:**
- Spacing before/after
- Text block: character count, **measured height using TextPainter**
- Text preview
- Image block: height

**Rendering Summary:**
```
Total estimated height: X
Available height: Y
Overflow: Z (if any)
=== End Rendering Page ===
```

### 4. Changed Scroll Physics
- Changed from `NeverScrollableScrollPhysics` to `ClampingScrollPhysics`
- This allows minor overflow to be handled gracefully
- Similar to cosmos_epub's approach (they use `BouncingScrollPhysics`)

## What to Look For

### Key Metrics to Compare:

1. **Pagination Phase:**
   - What is the calculated page height for each page?
   - Are page breaks happening at reasonable points?
   
2. **Rendering Phase:**
   - What is the measured height when the page is actually rendered?
   - Is there a discrepancy between pagination height and rendering height?

3. **The Gap:**
   - If there's still overflow, check: `rendering height - pagination height`
   - This gap tells us if we need a larger safety margin or if there's a bug

### Expected Behavior:

With the 100px safety margin:
- Pagination should calculate pages with height = (maxHeight - 100)
- Rendering should show actual height ≤ maxHeight
- Any overflow should be minimal and handled by the scroll view

### If Overflow Still Occurs:

Look for patterns in the logs:
1. **Is overflow consistent?** (e.g., always 63px) → might be a fixed padding issue
2. **Does it vary?** → might be related to text metrics vs actual rendering
3. **Only on certain pages?** → might be related to specific content (images, spacing)

## Cosmos EPUB Comparison

Key differences in their approach:
1. They use 120-150px safety margin (we use 100px now)
2. They calculate page breaks differently - they offset by 100px when finding break points
3. They use bouncing scroll physics (we use clamping)
4. They add explicit padding (top: 60, bottom: 40, left: 10, right: 10)

## Next Steps

If overflow persists after these changes:
1. Review the logs to find the discrepancy
2. Consider increasing safety margin to 120-150px
3. Check if Text widget adds implicit padding that TextPainter doesn't account for
4. Consider adding explicit padding like cosmos_epub does
5. Investigate if `textPainter.height` differs from actual rendered Text widget height

