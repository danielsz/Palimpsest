Palimpsest
==========

## Definition

From Wikipedia: 

>A palimpsest (/ˈpælɪmpsɛst/) is a manuscript page from a scroll or book from which the text has been scraped or washed off and which can be used again. The word "palimpsest" comes through Latin palimpsēstus from Ancient Greek παλίμψηστος (palímpsestos, “scratched or scraped again”) originally compounded from πάλιν (palin, “again”) and ψάω (psao, “I scrape”) literally meaning “scraped clean and used again”. Romans wrote on wax-coated tablets that could be smoothed and reused, and a passing use of the term "palimpsest" by Cicero seems to refer to this practice.

>The term has come to be used in similar context in a variety of disciplines, notably architectural archaeology.

## Purpose

 This minor mode for Emacs provides several strategies to remove text without permanently deleting it, useful to prose and fiction writers.
 Namely, it provides the following capabilities:

 - Send selected text to the bottom of the file 
 - Send selected text to a trash file 

## Installation

### Installing with el-get

Nothing to do. 

### Installing manually

Just put the palimpsest.el anywhere on your load path (or load the file manually), and that's it. **M-x palimpsest-mode**

If you want palimpsest to load automatically with your text files, andd the following in your init file. 

     ```emacs
	 (add-hook 'text-mode-hook 'palimpsest-mode)
	 ```
	
## Usage

- C-c C-r: Send selected text to the bottom 
- C-c C-q: Send selected text to trash file

## Configuration

You will find configuration options in palimpsest's customization group, wich will allow you to change the default key bindings and the trash file suffix. 
