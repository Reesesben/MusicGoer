//
//  CharacterController.swift
//  Thursday Afternoon Project
//
//  Created by Delstun McCray on 7/22/21.
//

import UIKit
class CharacterController {
    
    let pleaseSort = character.sorted(by: { $0.name < $1.name})
    //Aatrox, jhin,kha zix, rengar, yasuo , zed
    static let character = [
                                Character(name: "Aatrox", bio: "Once honored defenders of Shurima against the Void, Aatrox Aatrox and his brethren would eventually become an even greater threat to Runeterra, and were defeated only by cunning mortal sorcery. But after centuries of imprisonment, Aatrox was the first to find freedom once more, corrupting and transforming those foolish enough to try and wield the magical weapon that contained his essence. Now with stolen flesh, he walks Runeterra in a brutal approximation of his previous form, seeking an apocalyptic and long overdue vengeance.", photo: "Aatrox"),
                                
                                Character(name: "Alistar", bio: "Always a mighty warrior with a fearsome reputation, Alistar seeks revenge for the death of his clan at the hands of the Noxian empire. Though he was enslaved and forced into the life of a gladiator, his unbreakable will was what kept him from truly becoming a beast. Now, free of the chains of his former masters, he fights in the name of the downtrodden and the disadvantaged, his rage as much a weapon as his horns, hooves and fists.", photo: "Alistar"),
                                Character(name: "Amumu", bio: "Legend claims that Amumu is a lonely and melancholy soul from ancient Shurima, roaming the world in search of a friend. Doomed by an ancient curse to remain alone forever, his  touch is death, his affection ruin. Those who claim to have seen him describe a living cadaver, small in stature and wrapped in creeping bandages. Amumu has inspired myths, songs, and folklore told and retold for generations such that it is impossible to separate truth from fiction. ", photo: "Amumu"),
                                Character(name: "Anivia", bio: "Anivia is a benevolent winged spirit who endures endless cycles of life, death, and rebirth to protect the Freljord. A demigod born of unforgiving ice and bitter winds, she wields those elemental powers to thwart any who dare disturb her homeland. Anivia guides and protects the tribes of the harsh north, who revere her as a symbol of hope, and a portent of great change. She fights with every ounce of her being, knowing that through her sacrifice, her memory will endure, and she will be reborn into a new tomorrow.", photo: "Anivia"),
                                Character(name: "Annie", bio: "Dangerous, yet disarmingly precocious, Annie is a child mage with immense pyrokinetic power. Even in the shadows of the mountains north of Noxus, she is a magical outlier. Her natural affinity for fire manifested early in life through unpredictable, emotional outbursts, though she eventually learned to control these tricks. Her favorite includes the summoning of her beloved teddy bear, Tibbers, as a fiery beast hellbent on destruction. Lost in the perpetual innocence of childhood, Annie wanders the dark forests, always looking for someone to play with.", photo: "Annie"),
                                Character(name: "Azir", bio: "Azir Azir was a mortal emperor of Shurima in a far distant age, a proud man who stood at the cusp of immortality. His hubris saw him betrayed and murdered at the moment of his greatest triumph, but now, millennia later, he has been reborn as an Ascended being of immense power. With his buried city risen from the sand, Azir seeks to restore Shurima to its former glory.", photo: "azir"),
                                Character(name: "Fiddlesticks", bio: "Something has awoken in Runeterra. Something ancient. Something terrible. The ageless horror known as Fiddlesticks Fiddlesticks stalks the edges of mortal society, drawn to areas thick with paranoia where it feeds upon terrorized victims. Wielding a jagged scythe, the haggard, makeshift creature reaps fear itself, shattering the minds of those unlucky enough to survive in its wake. Beware the sounding of the crow, or the whispering of the shape that appears almost human... Fiddlesticks has returned.", photo: "fiddle"),
                                Character(name: "Jhin", bio: "Jhin is a meticulous criminal psychopath who believes murder is art. Once an Ionia Crest Ionian prisoner, but freed by shadowy elements within Ionia's ruling council, the serial killer now works as their cabal's assassin. Using his gun gun as his paintbrush, Jhin creates works of artistic brutality, horrifying victims and onlookers. He gains a cruel pleasure from putting on his gruesome theater, making him the ideal choice to send the most powerful of messages: terror.", photo: "Jhin"),
                                Character(name: "Rengar", bio: "Rengar is a ferocious vastayan trophy hunter who lives for the thrill of tracking down and killing dangerous creatures. He scours the world for the most fearsome beasts he can find, especially seeking any trace of Kha'Zix Kha'Zix, the void creature who scratched out his eye. Rengar stalks his prey neither for food nor glory, but for the sheer beauty of the pursuit.", photo: "Rengar"),
                                    Character(name: "Kha'Zix", bio: "The Void grows, and the Void adapts—in none of its myriad spawn are these truths more apparent than Kha'Zix Kha'Zix. Evolution drives the core of this mutating horror, born to survive and to slay the strong. Where it struggles to do so, it grows new, more effective ways to counter and kill its prey. Initially a mindless beast, Kha'Zix's intelligence has developed as much as its form. Now, the creature plans out its hunts, and even utilizes the visceral terror it engenders in its victims.", photo: "Khazix"),
                                Character(name: "Sion", bio: "A brutal warlord from a bygone era, Sion was revered in Noxus Crest Noxus for choking the life out of a Demacian king with his bare hands—but, denied the peace of death, he was resurrected to serve his empire once more. His indiscriminate slaughter claims all who stand in his way, regardless of allegiance, proving he has retained little of his former humanity. With crude armor bolted onto his rotten flesh, Sion continues to charge into battle with reckless abandon, struggling to remember his true self between the swings of his mighty axe.", photo: "sion"),
                                Character(name: "Yasuo", bio: "An Ionia Crest Ionian of deep resolve, Yasuo Yasuo is an agile swordsman who wields the air itself against his enemies. As a proud young man, he was falsely accused of murdering his master—unable to prove his innocence, he was forced to slay his own brother in self-defense. In time, his master's true killer was revealed, and his brother mysteriously returned from death, yet Yasuo still could not forgive himself for all he had done. Now, he wanders the world with only the wind to guide his blade.", photo: "Yasuo"),
                                Character(name: "Zed", bio: "Utterly ruthless and without mercy, Zed Zed is the leader of the The Order of The Shadows Crest.jpg Order of Shadow, an organization he created with the intent of militarizing Ionia Crest Ionia’s magical and martial traditions to drive out Noxian invaders. During the war, desperation led him to unlock the secret shadow form—a malevolent spirit magic as dangerous and corrupting as it is powerful. Zed has mastered all of these forbidden techniques to destroy anything he sees as a threat to his nation, or his new order.", photo: "Zed")]
}