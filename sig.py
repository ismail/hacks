#!/usr/bin/env python3
import numpy as np
import re

quotes = {
    "For it is in giving that we receive.":
    "St. Francis of Assisi, patron saint of animals and ecology",
    "In ancient times cats were worshipped as gods; they have not forgotten this.":
    "Terry Pratchett",
    "You will become way less concerned with what other people think of you when you realize how seldom they do.":
    "David Foster Wallace, Infinite Jest",
    """
    Entrenched in both ancient and modern cultural tradition,
    the pursuit of happiness is a popular preoccupation around the world.
    """:
    "Ed Diener",
    "Raffiniert ist der Herrgott, aber boshaft ist er nicht.":
    "Albert Einstein",
    "Everything is the way it is because it got that way.":
    "D'Arcy Wentworth Thompson",
    "Every one suspects himself of at least one of the cardinal virtues.":
    "F. Scott Fitzgerald",
    "Nothing is true, everything is permitted.":
    "Hasan-i Sabbāh",
    "If there is no God, then everything is permitted.":
    "Dmitri Karamazov",
    """
    If it weren't for the fact that the TV set and the refrigerator are so far apart,
    some of us wouldn't get any exercise at all.
    """:
    "Joey Adams",
    """
    Any justice which is only justice soon degenerates into something less than justice.
    It must be saved by something which is more than justice.
    """:
    "Reinhold Niebuhr",
    "I come from a line of pessimists. My mother was a pessimist.":
    "Daniel Kahneman",
    """
    Aus so krummem Holze, als woraus der Mensch gemacht ist,
    kann nichts ganz Gerades gezimmert werden.
    """:
    "Immanuel Kant",
    "Never attribute to malice that which is adequately explained by stupidity.":
    "Hanlon's razor",
    """
    I do not fear death. I had been dead for billions and billions of years before I was born,
    and had not suffered the slightest inconvenience from it.
    """:
    "Mark Twain",
    "When I play with my cat, how do I know she is not passing time with me rather than I with her?":
    "Montaigne",
    "Jenseits von richtig und falsch liegt ein Ort, an dem treffen wir uns.":
    "Rūmī",
    """
    My German engineer, I think, is a fool. He thinks nothing empirical is knowable.
    I asked him to admit that there was no rhinoceros in the room, but he wouldn't.
    """:
    "Bertrand Russell on early Ludwig Wittgenstein",
    """
    More than any other time in history mankind faces a crossroads.
    One path leads to despair and utter hopelessness, the other to total extinction.
    Let us pray we have the wisdom to choose correctly.
    """:
    "Woody Allen",
    """
    How it is that anything so remarkable as a state of consciousness comes about
    as a result of irritating nervous tissue, is just as unaccountable as
    the appearance of the djinn when Aladdin rubbed his lamp in the story.
    """:
    "Thomas Henry Huxley",
    """
    There is a cult of ignorance in the United States, and there has always been.
    The strain of anti-intellectualism has been a constant thread winding its way through
    our political and cultural life, nurtured by the false notion that democracy means that
    my ignorance is just as good as your knowledge.
    """:
    "Isaac Asimov",
    "I would never belong to any club that would have me as a member.":
    "Groucho Marx",
    "Every time I find the meaning of life, they change it.":
    "Reinhold Niebuhr",
    "What is youth? A dream. What is love? The dream's content.":
    "Søren Kierkegaard, Either/Or: A Fragment of Life",
    "I've finally stopped getting dumber.":
    "The epitaph on Paul Erdős's grave",
    """
    Sometimes I go about in pity for myself, and all the while,
    a great wind carries me across the sky.
    """:
    "Ojibwe saying",
    """
    A designer knows that they have achieved perfection not when there is nothing left to add,
    but when there is nothing left to take away.
    """:
    "de Saint-Exupery's Law of Design",
    """
    "Better" is the enemy of "good".
    """:
    "Edison's Law",
    "Half of everything you hear in a classroom is crap. Education is figuring out which half is which.":
    "Larrabee's Law",
    "When the hardware is working perfectly, the really important visitors don't show up.":
    "Atkin's Law of Demonstrations",
    "A good plan violently executed now is better than a perfect plan next week.":
    "Patton's Law of Program Planning",
    "Do what you can, where you are, with what you have.":
    "Roosevelt's Law of Task Planning",
    "It is difficult to get a man to understand something when his salary depends on his not understanding it.":
    "Upton Sinclair"
}

end = """
SUSE Software Solutions Germany GmbH, Maxfeldstrasse 5, 90409 Nuernberg, Germany
GF: Felix Imendörffer (HRB 36809, AG Nürnberg)"""

quote, author = np.random.default_rng().choice(list(quotes.items()))
quote = quote.strip()
quote = re.sub(r"\n[ ]+", r"\n", quote, flags=re.UNICODE)

print(f"{quote.strip()}\n\n— {author}\n{end}")
