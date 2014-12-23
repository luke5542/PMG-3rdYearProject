module ridgway.pmgcrawler.generators.generator;

import dsfml.graphics;

alias StartColor = Color.Green;
alias EndColor = Color.Red;
alias Rect!(uint) UIntRect;

interface Generator
{
	Image generateImage();
}