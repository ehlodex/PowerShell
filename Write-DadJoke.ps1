<#
  .SYNOPSIS
    Tells you a witty and clever joke from a small repertoire.
  
  .DESCRIPTION
    This script will randomly select one of the best jokes in the world then tell it to you.
  
  .PARAMETER durr
    This "hidden" parameter simply mocks you. Hurr durr!

  .EXAMPLE
    .\Write-DadJoke.ps1 -durr ...Did you really need an example?

  .LINK
    https://technet.microsoft.com/en-us/library/hh847834.aspx

  .LINK
    http://niceonedad.com/
    
  .LINK
    https://www.livin3.com/100-bad-dad-jokes-that-will-make-you-laugh-or-cringe
  
  .NOTES
    Written by:
    Joshua Burkholder, Teller of Dad Jokes
#>

[CmdletBinding()]                                                                                                               # Enabled advanced parameter features, such as decorator lines
Param([switch]$durr);
# For maximum readability, enable syntax highlighting                                                                           # # # # # # # #
Set-StrictMode -Version Latest                                                                                                  # Require all variables to be declared

# Configure Script-Specific Settings                                                                                            # # # # # # # #
  # Initialize Script (Local) Variables                                                                                         # # # #
  $MollySeconds = 500;          #default: 500                                                                                   # Milli, Molly, Mary, whoever... Set to 0 to disable.
  $Pauses = 3;                  #default: 3                                                                                     # Multiplier for MollySeconds. Set to 0 for a single delay.
  $Symbol = ".";                #default: "."                                                                                   # Symbol to write between MollySeconds. Set to "" for none.
  
# PowerShell Script                                                                                                             # # # # # # # #
  $dad = @();                                                                                                                   # Initialize a new array (J.B. <= it's been inital-ized)
  $dad += @{"q" = "I bought shoes from a drug dealer once"; "a" = "I don't know what he laced them with, but I was tripping all day."};
  $dad += @{"q" = "A ham sandwich walks into a bar and orders a beer."; "a" = "The bartender says 'Sorry, we dont serve food here'."};
  $dad += @{"q" = "I'm reading a book on antigravity"; "a" = "I just can't seem to put it down."};                              # antigravity
  $dad += @{"q" = "How can you tell if ants are male or female?"; "a" = "They're all female, otherwise they'de be uncles."};    # ants
  $dad += @{"q" = "How many apples grow on a tree?"; "a" = "All of them."};                                                     # apple tree
  $dad += @{"q" = "Did you hear about the new restaurant on the moon?"; "a" = "It has great food, but no atmosphere."};         # atmosphere
  $dad += @{"q" = "Don't trust atoms"; "a" = "they make up everything."};                                                       # atoms
  $dad += @{"q" = "People don't like having to bend over to get their drinks."; "a" = "We really need to raise the bar"};       # bar
  $dad += @{"q" = "I gave away all of my dead batteries today."; "a" = "Free of charge."};                                      # batteries
  $dad += @{"q" = "How do you make a tissue dance?"; "a" = "Put a little boggie in it."};                                       # boogie
  $dad += @{"q" = "I'm not addicted to brake fluid"; "a" = "I can stop whenever I want."};                                      # brakes
  $dad += @{"q" = "What did the buffalo say to his son when he left for college?"; "a" = "Bison."};                             # buffalo
  $dad += @{"q" = "Did you hear about the guy who stole a calendar?"; "a" = "He got twelve months."};                           # calendar
  $dad += @{"q" = "My kids asked me to put the cat out."; "a" = "I didn't know it was on fire."};                               # cat on fire
  $dad += @{"q" = "If prisoners could take their own mugshots"; "a" = "they'd be called cellfies."};                            # cellfies
  $dad += @{"q" = "Did you hear about the cheese factory explosion in France?"; "a" = "There was nothing left but de Brie."};   # cheese
  $dad += @{"q" = "I cut my finger chopping cheese"; "a" = "but I think I may have grater problems."};                          # cheese grater
  $dad += @{"q" = "What did the mountain climber name his son?"; "a" = "Cliff."};                                               # cliff
  $dad += @{"q" = "Wanna hear a joke about construction?"; "a" = "Nevermind, I'm still working on it."};                        # construction
  $dad += @{"q" = "Why does a chicken coop only have two doors?"; "a" = "Because if it had four, it'd be a chicken sedan."};    # coop
  $dad += @{"q" = "Is this pool safe for diving?"; "a" = "It deep ends."};                                                      # diving
  $dad += @{"q" = "Two guys walk into a bar"; "a" = "The third one ducks."};                                                    # ducks
  $dad += @{"q" = "Why do you never see elephants hiding in trees?"; "a" = "Because they're so good at it."};                   # elephants
  $dad += @{"q" = "I'm terrified of elevators."; "a" = "I'm going to start taking steps to avoid them."};                       # elevators
  $dad += @{"q" = "What's ET short for?"; "a" = "Because he's only got little legs."};                                          # et
  $dad += @{"q" = "I used to hate facial hair"; "a" = "but then it grew on me."};                                               # facial hair
  $dad += @{"q" = "What's Forrest Gump's password?"; "a" = "1Forrest1"};                                                        # forrest
  $dad += @{"q" = "What do you get when you cross a snowman with a vampire?"; "a" = "Frostbite."};                              # frostbite
  $dad += @{"q" = "What do you call a fish with no eyes?"; "a" = "A Fsh."};                                                     # fsh
  $dad += @{"q" = "Without geometry"; "a" = "life is pointless!"};                                                              # geometry
  $dad += @{"q" = "That must be a really popular graveyard."; "a" = "I'll bet people are dying to get in there."};              # graveyard
  $dad += @{"q" = "I deleted all the German contacts from my phone."; "a" = "Now it's Hans free."};                             # hans-free
  $dad += @{"q" = "How much does a hipster weigh?"; "a" = "An instagram."};                                                     # hipster
  $dad += @{"q" = "Why do bees hum?"; "a" = "Because they don't know the words."};                                              # hum
  $dad += @{"q" = "Dad, I'm hungry."; "a" = "Hi, Hungry, I'm Dad."};                                                            # hungry
  $dad += @{"q" = "Where do you learn to make ice cream?"; "a" = "Sundae School."};                                             # ice cream
  $dad += @{"q" = "What do you call a fake noodle?"; "a" = "An impasta."};                                                      # impasta
  $dad += @{"q" = "What do you call an elephant that doesn't matter?"; "a" = "Irrelephant."};                                   # irrelephant
  $dad += @{"q" = "I'll call you later."; "a" = "Don't call me Later, call me Dad."};                                           # later
  $dad += @{"q" = "Did you hear about the guy who invented Lifesavers candy?"; "a" = "They say he made a mint."};               # lifesavers
  $dad += @{"q" = "Can February march?"; "a" = "No, but April may."};                                                           # march
  $dad += @{"q" = "A red and a blue ship have just collided in the Caribbean"; "a" = "Apparently the survivors are marooned"};  # marooned
  $dad += @{"q" = "Have you heard of the band 999MB?"; "a" = "They haven't gotten a gig yet."};                                 # MB=1000*1000; MiB=1024*1024
  $dad += @{"q" = "Milk is the fastest liquid on Earth"; "a" = "Its pasteurized before you even see it."};                      # milk
  $dad += @{"q" = "I heard there's a new store called 'Moderation.'"; "a" = "They have everything in there."};                  # moderation
  $dad += @{"q" = "Last night, I dreamt I was a muffler."; "a" = "I woke up exhausted."};                                       # muffler
  $dad += @{"q" = "Why did the coffee file a police report?"; "a" = "It got mugged."};                                          # mugged
  $dad += @{"q" = "What do you call chesse that isn't yours?"; "a" = "nacho cheese."};                                          # nacho cheese
  $dad += @{"q" = "Did you hear about the guy who invented knock-knock jokes?"; "a" = "He just won a 'no-bell' prize."};        # no-bell
  $dad += @{"q" = "Why can't you have a nose that's 12 inches long?"; "a" = "Because it would be a foot."};                     # nose-foot
  $dad += @{"q" = "Why did the scarecrow win an award?"; "a" = "Because he was outstanding in his field."};                     # outstanding
  $dad += @{"q" = "I needed a password 8 characters long"; "a" = "so I picked Snow White and the Seven Dwarves."};              # password
  $dad += @{"q" = "How does a penguin build its house?"; "a" = "Igloos it together."};                                          # penguin
  $dad += @{"q" = "What does an annoying pepper do?"; "a" = "Gets jalapeño business."};                                         # peppers
  $dad += @{"q" = "What do you call a pony with a sore throat?"; "a" = "A little horse."};                                      # pony
  $dad += @{"q" = "How do prisoners communicate with each other?"; "a" = "Cell phones."};                                       # prisoners
  $dad += @{"q" = "What do you call a fat psychic?"; "a" = "A four-chin teller."};                                              # psychic
  $dad += @{"q" = "Why can't you hear a pterodactyl go to the bathroom?"; "a" = "Because the pee is silent."};                  # pterodactyl
  $dad += @{"q" = "Two antennae got married"; "a" = "The wedding wasn't much, but the reception was incredible."};              # reception
  $dad += @{"q" = "I knew I shouldn't have had the seafood"; "a" = "I'm feeling a little eel."};                                # seafood
  $dad += @{"q" = "Why do crabs never give to charity?"; "a" = "Because they're shellfish."};                                   # shellfish
  $dad += @{"q" = "I quit my old job in a shoe recycling factory."; "a" = "It was sole destroying."};                           # shoes
  $dad += @{"q" = "I needed a password that was eight characters long"; "a" = "so I picked Snow White and the Seven Dwarves."}; # snow white
  $dad += @{"q" = "Why did the can crusher quit his job?"; "a" = "Because it was soda-pressing."};                              # soda
  $dad += @{"q" = "What do you call a shady Italian neighbourhood?"; "a" = "The Spaghetto."};                                   # spaghetto
  $dad += @{"q" = "What's brown and sticky?"; "a"= "A stick."};                                                                 # sticky
  $dad += @{"q" = "What's the advantage of living in Switzerland?"; "a" = "Well, the flag is a big plus."};                     # switzerland
  $dad += @{"q" = "Wanna hear a joke about paper?"; "a" = "Nevermind; it's tearable."};                                         # tearable
  $dad += @{"q" = "A termine walks into a bar and asks:"; "a" = "Is the bar tender here?"};                                     # termite
  $dad += @{"q" = "Our wedding was so beautiful"; "a" = "even the cake was in tiers."};                                         # tiers
  $dad += @{"q" = "What time did the man go to the dentist?"; "a" = "Tooth hurty."};                                            # tooth hurty
  $dad += @{"q" = "Why couldn't the bicyle stand up by itself?"; "a" = "It was two tired."};                                    # two tired
  $dad += @{"q" = "I would never buy anything with velcro."; "a" = "It's a total rip-off."};                                    # velcro
  $dad += @{"q" = "What lies at the bottom of the ocean and twitches?"; "a" = "A nervous wreck."};                              # wreck
  $dad += @{"q" = "I hate jokes about German sausage."; "a" = "They're the wurst."};                                            # wurst
  #$dad += @{"q" = ""; "a" = ""};
  If ($durr) { Write-Host "           .-._"; Write-Host "          {_}^ )o";
  Write-Host " {\________//~``     hurr durr! Yaey, hooman, you found the durr switch."
  Write-Host "  (         )"; Write-Host "  /||~~~~~||\"; Write-Host " |_\\_    \\_\_"; Write-Host " `"`' `"`"`'    `"`"`'`"`'   "; #"
  } Else {
  $joke = Get-Random -Minimum 0 -Maximum $dad.GetUpperBound(0);															        # Pick a random joke - but they're all awesome!
  Write-Host "`n$($dad[$joke].q) " -NoNewLine;                                                                                  # Lead-in
  For ($dramaticPause = 0; $dramaticPause -le $Pauses; $dramaticPause++) {                                                      # 
    Start-Sleep -Milliseconds $MollySeconds; If ($dramaticPause -lt $Pauses) {Write-Host $Symbol -NoNewLine;};                  #  Wait for it...wait for it...
  };                                                                                                                            # 
  Write-Host " $($dad[$joke].a)`n"; Start-Sleep -Milliseconds ($MollySeconds * 2);                                              # BAM!
};
