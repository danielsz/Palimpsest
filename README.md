Palimpsest
==========

## Definition

From Wikipedia: 

>A palimpsest (/ˈpælɪmpsɛst/) is a manuscript page from a scroll or book from which the text has been scraped or washed off and which can be used again. The word "palimpsest" comes through Latin palimpsēstus from Ancient Greek παλίμψηστος (palímpsestos, “scratched or scraped again”) originally compounded from πάλιν (palin, “again”) and ψάω (psao, “I scrape”) literally meaning “scraped clean and used again”. Romans wrote on wax-coated tablets that could be smoothed and reused, and a passing use of the term "palimpsest" by Cicero seems to refer to this practice.

>The term has come to be used in similar context in a variety of disciplines, notably architectural archaeology.

## Purpose

This minor mode for Emacs provides several strategies to remove text without permanently deleting it. Namely, it provides the following capabilities:

 - Send selected text to the bottom of the file 
 - Send selected text to a trash file 

Much like code, the process of writing text is a progression of revisions where content gets transformed and refined. During these iterations, it is often desirable to move text instead of deleting it: you may have written a sentence that doesn't belong in the paragraph you're editing right now, but it might very well fit somewhere else. Since you don't know where exactly, you'd like to put it out of the way, not discard it entirely. Palimpsest saves you from the traveling back and forth between your current position and the bottom of your document (or another *draft* or *trash*  document).

Next time you're writing fiction, non-fiction, a journalistic piece or a blog post using Emacs, give palimpsest-mode a try. You might even try it while coding in a functional language, moving stuff around sprightly, aided by an abstraction reminiscent of the Read-Eval-Print loop, yet completely orthogonal. 

## Installation

### Installing with el-get

Nothing to do (except declaring `palimpsest-mode` along with your packages).

### Installing with ELPA

Please make sure you have Marmalade or MELPA in your package archives.

    (setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
	                         ("marmalade" . "http://marmalade-repo.org/packages/")
							 ("melpa" . "http://melpa.milkbox.net/packages/")))
													  
### Installing manually

Just put the palimpsest.el anywhere on your load path (or load the file manually). `M-x palimpsest-mode` will toggle it on or off.

If you want palimpsest to load automatically when writing textual files, andd the following in your init file. 

	 (add-hook 'text-mode-hook 'palimpsest-mode)
	
## Usage

- `C-c C-r`: Send selected text to the bottom `(palimpsest-move-region-to-bottom)`
- `not-defined`: Send selected text to the top `(palimpsest-move-region-to-top)`
- `C-c C-q`: Send selected text to trash file `(palimpsest-move-region-to-trash)`

## Configuration

Configuration options are available in palimpsest's customization group, where you are given a chance to reassign key bindings as well as define your preferred suffix for the *trash* (or *draft*) file. 

P.S. [Follow][follow_me] me on Twitter.

[follow_me]: https://twitter.com/intent/user?screen_name=danielszmu "Follow @danielszmu"
