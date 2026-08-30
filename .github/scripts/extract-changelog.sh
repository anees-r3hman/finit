#!/bin/sh
#
# Extract the topmost release entry from doc/ChangeLog.md and unwrap
# its paragraphs, so the GitHub releases page can wrap them to the
# browser width instead of showing the hard 72-column breaks.
#
# Usage: .github/scripts/extract-changelog.sh < doc/ChangeLog.md > release.md
#
set -e

# The entry sits between the first two underlines, minus the blank
# line separating it from the next heading.
awk '/^-----*$/{if (x == 1) exit; x=1;next}x' | head -n -1 |

# Blank lines, headings, blockquotes, tables, and list items (at any
# indent) start a new block, everything else continues the current one.
awk '
function flush() { if (buf) print buf; buf = "" }
{
    if (/^$/) { flush(); print; blank = 1; next }
    if (/^ *([-*] |[0-9]+\. |[>#|])/ || blank || !buf || brk)
        { flush(); buf = $0 }
    else
        { sub(/^ +/, ""); buf = buf " " $0 }
    blank = 0
    brk = /  $/
}
END { flush() }
'
