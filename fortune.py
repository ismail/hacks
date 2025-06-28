#!/usr/bin/env python3

import random
import re
import sys
import unittest

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
    "All money is a matter of belief. When the world loses faith, the currency becomes worthless paper.": "Adam Smith",
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
    "Zweifle nicht an dem der sagt, er habe Angst, aber habe Angst vor dem, der sagt, er habe keine Zweifel.": "Erich Fried",
    "Everybody is disappointed in me at some point.": "Larry David",
    "A person often meets his destiny on the road he took to avoid it.": "Jean de la Fontaine",
    "Wherever you go, there you are.": "Thomas a Kempis",
    "I don't believe in anything you have to believe in.": "Fran Lebowitz",
    "The universe is transformation, life is judgement.": "Marcus Aurelius",
    "Every one shall meet what he wishes to avoid by running away.": "Imam Ali Ibn Abi Talib",
    "Where all think alike, no one thinks very much.": "Walter Lippmann",
    "Whenever you find yourself on the side of the majority, it is time to pause and reflect.": "Mark Twain",
    "Any sufficiently advanced incompetence is indistinguishable from malice.": "Fred Clark's Law",
    "Inspiration is for amateurs. The rest of us just show up and get to work.": "Chuck Close",
    "The optimist thinks this is the best of all possible worlds. The pessimist fears it is true.": "J. Robert Oppenheimer",
    "Half the harm that is done in this world is due to people who want to feel important. They don't mean to do harm; but the harm does not interest them. Or they do not see it, or they justify it because they are absorbed in the endless struggle to think well of themselves.": "T.S. Eliot",
    "Until one has loved an animal, a part of one's soul remains unawakened.": "Anatole France",
}

def normalize_quote(quote):
    return '\n'.join(line.strip() for line in quote.strip().split('\n'))

def get_random_quote():
    quote, author = random.choice(list(quotes.items()))
    return normalize_quote(quote), author

def format_quote(quote, author):
    if author:
        return f"{quote.strip()} — {author}"
    return quote.strip()

class TestFortune(unittest.TestCase):
    def test_get_random_quote(self):
        normalized_quotes = {normalize_quote(q): q for q in quotes.keys()}
        for _ in range(100):
            quote, author = get_random_quote()
            self.assertIn(quote, normalized_quotes.keys())
            original_quote = normalized_quotes[quote]
            self.assertEqual(quotes[original_quote], author)

    def test_format_quote(self):
        self.assertEqual(format_quote("test", "author"), "test — author")
        self.assertEqual(format_quote("test", None), "test")

    def test_normalize_quote(self):
        multi_line_quote = """
        What is youth?
        A dream.
                                         
        What is love?
        The dream's content.
        """
        self.assertEqual(
            normalize_quote(multi_line_quote),
            "What is youth?\nA dream.\n\nWhat is love?\nThe dream's content."
        )

        single_line = "  Hello World  \t\r\n"
        self.assertEqual(normalize_quote(single_line), "Hello World")

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "test":
        sys.argv.pop(1)
        unittest.main()
    else:
        quote, author = get_random_quote()
        print(format_quote(quote, author))
