---
title: new blog engine
author: llimiagu
date: 2022-02-23
---

So after trying hugo and zola for building a static blog, I've decided to make my own 'blog engine'. Well, it's just a Makefile and some scripts. I rather prefer the simplicity of this approach to a more featureful system because the price for that is a lot of hidden complexity.

I use pandoc for rendering markdown to html, and a filter written in lua for piping the code blocks into pygmentize. Also some awk one liners to generate the list of posts. The styling is minimal, I use water.css with minimal tweaks, to taste. Finally, I minify all the output.

Basically it's just that. Very simple and lightweight.

