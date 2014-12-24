module ridgway.pmgcrawler.generators.generator;

import dsfml.graphics;

alias StartColor = Color.Green;
alias EndColor = Color.Red;

interface Generator
{
	Image generateImage();
}