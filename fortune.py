#!/usr/bin/env python3

import random
import re
import time

quotes = {
    "Never attribute to malice that which is adequately explained by stupidity.": "Hanlon's razor",
    "I don't want to belong to any club that will accept me as a member.": "Groucho Marx",
    "Every time I find the meaning of life, they change it.": "Reinhold Niebuhr",
    """
    What is youth?
    A dream.

    What is love?
    The dream's content.
    """: "Søren Kierkegaard - Either/Or: A Fragment of Life",
    "I've finally stopped getting dumber.": "The epitaph on Paul Erdős's grave",
    "Sometimes I go about in pity for myself, and all the while, a great wind carries me across the sky.": "Ojibwe saying",
    "Attention is the rarest and purest form of generosity.": "Simone Weil",
    "Denken tut weh.": "Georg Simmel",
    "When you are dead, you do not know you are dead. It's only painful & difficult for others. The same applies when you are stupid.": "Ricky Gervais",
    "People use statistics as a drunk uses a lamppost — for support rather than illumination.": "A. E. Housman",
    "The tree which moves some to tears of joy is in the eyes of others only a green thing which stands in the way... As a man is, so he sees.": "William Blake",
    "When the facts change, I change my mind. What do you do, sir?": "John Maynard Keynes",
    "When information goes ‘in one ear and out the other’ it's often because it doesn’t have anything to stick to.": "Joshua Foer",
    "Nothing is more unbearable, once one has it, than freedom.": "James Baldwin",
    "For every complex problem there is an answer that is clear, simple, and wrong.": "H. L. Mencken",
    "All of humanity’s problems stem from man’s inability to sit quietly in a room alone.": "Blaise Pascal",
    "All good solutions have one thing in common: they are obvious, but only in hindsight.": "Eli Goldratt",
    "It ain't what you don't know that gets you into trouble. It's what you know for sure that just ain't so.": "Josh Billings",
    "A person often meets his destiny on the road he took to avoid it.": "Jean de la Fontaine",
    "The universe is transformation, life is judgement.": "Marcus Aurelius",
    "Every one shall meet what he wishes to avoid by running away.": "Imam Ali Ibn Abi Talib",
    "Where all think alike, no one thinks very much.": "Walter Lippmann",
    "Whenever you find yourself on the side of the majority, it is time to pause and reflect.": "Mark Twain",
    "Any sufficiently advanced incompetence is indistinguishable from malice.": "Fred Clark's Law",
    "Inspiration is for amateurs. The rest of us just show up and get to work.": "Chuck Close",
}

random.seed(time.time())
quote, author = random.choice(list(quotes.items()))
quote = quote.strip()
quote = re.sub(r"\n[ ]+", r"\n", quote, flags=re.UNICODE)

print(f"{quote.strip()}", end="")
if author:
    print(f" — {author}")
else:
    print()
