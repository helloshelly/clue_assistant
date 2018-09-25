%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DOCUMENTATION
% Student Names: Kelly Su, Shelly Hsu
%
% WHAT OUR PROJECT CAN DO:
% Our project can display information, ask for options, or display false suggestions at any time.
% Our project below keeps track your cards and who has shown their cards to you.
% Our project keeps track of other peoples claims and deduces what cards they possibily have from inferring from other player's actions
%   - For example, if player2 does not show a card that player1 claimed, player2 definitely DOES NOT have that card
%   - Another example, if player2 does show player1 a card, then player2 may have one of the three cards.
% Deduces and removes claims, once proven as fact.
%
% HOW TO BEGIN PLAY:
% First, consult this file into SWI-Prolog. Then, type in 'start.'
% After it starts, you are required to answer the questions needed to properly register all initial information.
% After 'start.' you can now either type in 'display.', 'options.', or 'make_false_suggestion.'
% You can now also begin inputting the other player's actions, first starting with 'player1.', then 'player2.' up to 'player6.'
% At anytime after you input a player's action, you can type in any of the above commands described above.
% 
% We believe our project can perform up to the top level, with smooth I/O implemented.
% Thank you for such a fun and intriguing project! 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Beginning dynamic variables
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- dynamic validsuspect/1, validroom/1, validweapon/1, player/1, player1/0,player2/0,player3/0,
    player4/0,player5/0,player6/0,player_list/6, status_list/6, player/2, claim/5, fact/2,
    possible_cards/2, your_cards/1.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Start function. Registers everyone in the beginning and the user's cards.
% *Special note: command function too!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start:- 
    put(10), put(10), put(10),
    write("Hello! Please allow me to introduce myself. I am your very own, personal, Clue Assistant."),
    put(10), write("Im here to guide you in winning the game Clue!"), put(10), put(10), put(10),
    register_players(A,B,C,D,E,F),
    self_or_opponent([A,B,C,D,E,F],[SA,SB,SC,SD,SE,SF]),
    assert(player_list([A,B,C,D,E,F])),
    assert(status_list([SA,SB,SC,SD,SE,SF])),
    eliminate_own_cards,
    insert_players_possible_cards(A,SA),
    insert_players_possible_cards(B,SB),
    insert_players_possible_cards(C,SC),
    insert_players_possible_cards(D,SD),
    insert_players_possible_cards(E,SE),
    insert_players_possible_cards(F,SF),
    explanation.
    
    
register_players(scarlet,B,C,D,E,F):-
    write("First, tell me the order of the players that are playing."), put(10), 
    write("Please begin with the second player, since Scarlet is always the first player."), put(10),
    write("Type only their surname, uncapitalized and without any spaces. For example, type in mustard."), put(10),
    write("Oh! And when youre done, please type none. if that player is not playing."), put(10), put(10), put(10),

    write("Second Player: "), read(B), put(10), player(B), 
    write("Third Player: "), read(C), put(10), player(C),
    write("Fourth Player: "), read(D), put(10), player(D),
    write("Fifth Player: "), read(E), put(10), player(E),
    write("Sixth Player: "), read(F), put(10), player(F), put(10), put(10),

    write("It looks like the following characters are playing!"), put(10), write(scarlet), put(10),
    print_players(B), print_players(C), print_players(D), print_players(E), print_players(F), put(10), put(10).


self_or_opponent([A,B,C,D,E,F],[SA,SB,SC,SD,SE,SF]):-
    write("Which, of the above players, are you? "),
    read(X), put(10), put(10),
    assign_status(A,X,SA),
    assign_status(B,X,SB),
    assign_status(C,X,SC),
    assign_status(D,X,SD),
    assign_status(E,X,SE),
    assign_status(F,X,SF).
  
  
eliminate_own_cards:-
    write("Alright! Let us begin this fun game of Clue."), put(10), put(10), put(10), 
    write("I need to know the cards you currently hold, one at a time. "),
    write("After entering them all, please type none.. "), read(X), put(10), read_cards(X, List),
    retract_cards(List), assert(your_cards(List)), put(10), put(10), put(10).
   
    
read_cards(none, []).
read_cards(X, List):-
    read_cards_helper(NewList),
    append([X], NewList, List).
    
read_cards_helper([H|T]):-
    write("Next card (or type in none. if youre done): "), 
    read(H), put(10), 
    dif(H,none),
    read_cards_helper(T).
read_cards_helper([]).
    
    
retract_cards([X]):-
    retract_single_card(X).
retract_cards([H|T]):-
    retract_single_card(H),
    retract_cards(T).
retract_single_card(X):- 
    validsuspect(X),
    retract(validsuspect(X)).
retract_single_card(X):-
    validroom(X),
    retract(validroom(X)).
retract_single_card(X):-
    validweapon(X),
    retract(validweapon(X)).
    
       
insert_players_possible_cards(_, Status):- 
   \+ (Status == opponent).
insert_players_possible_cards(Player_name, _):- 
    findall(X,validsuspect(X),SL),
    findall(Y,validweapon(Y),WL),
    findall(Z,validroom(Z),RL),
    insert_possibilities(Player_name, SL),
    insert_possibilities(Player_name, WL),
    insert_possibilities(Player_name, RL).

insert_possibilities(Player_name, [H]):-
    assert(possible_cards(Player_name, H)).
insert_possibilities(Player_name, [PossH|PossT]):-
    assert(possible_cards(Player_name, PossH)),
    insert_possibilities(Player_name, PossT).
    
    
explanation:-
    write("Thanks! Here is how I can better assist you. "),
    write("Ill need you to follow all the rules, or else I wont be able to help you out!"), put(10),  put(10),
    write("The game will go in order that you registered them. "),
    write("So for example, the command player1 will play the turn of the first player, which is scarletp. "), 
    write("Next, you will keep going in order. Type in the command line: player1., then player2., all the way up to player6.. "),
    write("After that, you can restart back to player1.."), put(10), put(10),
    write("You can also check how you are doing with the command display.. "),
    write("It will show you everything that I have kept track throughout the game! " ), 
    write("If you forgot what I can do for you, I also have the command options. to remind you! "), 
    write("One last thing, with make_false_suggestion., I can also provide you information to throw your opponents off when its your turn to suggest something."), put(10), put(10),
    write("Anyways, that is all I have for you! Lets go beat Professor Eiselt together!"), put(10), put(10), put(10). 
    
    
assign_status(Player,X,Status):-
    X == Player,
    Status = self.
assign_status(Player,_,Status):-
    Player == none,
    Status = none.
assign_status(_,_,Status):-
    Status = opponent.

print_players(Character):-
    Character == none.
print_players(Character):-
    write(Character), put(10).
   
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Player functions. User will input them from player1 - player6. All depend on player()
% *Special note: command function too!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

player(_,_,Status,_):-
    Status == none,
    write("It looks like no one is playing this turn... would you mind restarting, by typing in player1.?").
player(Number,Player_name,Status,X):-
    Status == self,
    make_AccOrSugg(X,SL,WL,RL),
    write_AccOrSugg(X,SL,WL,RL),
    self_suggestion(SuggSuspect, SuggWeapon, SuggRoom),
    Next_opponent_number is Number + 1,
    read_opponent_input(Next_opponent_number, SuggSuspect, SuggWeapon, SuggRoom, Player_name).
player(Number,Player_name,Status,_):- 
    Status == opponent,
    observe(Number, Player_name).
   
    
player1:- 
    player_list([A,_,_,_,_,_]),
    status_list([SA,_,_,_,_,_]),
    put(10), put(10),
    player(1,A,SA,X),
    put(10), put(10), 
    write("The command to enter the next persons actions is player2!"), put(10), put(10).
   
    
player2:-
    player_list([_,B,_,_,_,_]),
    status_list([_,SB,_,_,_,_]),
    put(10), put(10),
    player(2,B,SB,X),
    put(10), put(10), 
    write("The command to enter the next persons actions is player3!"), put(10), put(10).
   
    
player3:-
    player_list([_,_,C,_,_,_]),
    status_list([_,_,SC,_,_,_]),
    put(10), put(10),
    player(3,C,SC,X),
    put(10), put(10), 
    write("The command to enter the next persons actions is player4!"), put(10), put(10).
    
    
player4:-
    player_list([_,_,_,D,_,_]),
    status_list([_,_,_,SD,_,_]),
    put(10), put(10), 
    player(4,D,SD,X),
    put(10), put(10), 
    write("The command to enter the next persons actions is player5!"), put(10), put(10).


player5:-
    player_list([_,_,_,_,E,_]),
    status_list([_,_,_,_,SE,_]),
    put(10), put(10),
    player(5,E,SE,X),
    put(10), put(10), 
    write("The command to enter the next persons actions is player6!"), put(10), put(10).
   
    
player6:-
    player_list([_,_,_,_,_,F]),
    status_list([_,_,_,_,_,SF]),
    put(10), put(10), 
    player(6,F,SF,X),
    put(10), put(10), 
    write("The command to enter the next persons actions is player1!"), put(10), put(10).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Option function to remind the user their commands.
% Display functions to remind the user their information and their choices.
% *Special note: command function too!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  

display:-
    findall(F,fact(F,_),FactsNameList),
    findall(G,fact(_,G),FactsCardsList),
    findall(X,validsuspect(X),SuspectList),
    findall(Y,validroom(Y),RoomList),
    findall(Z,validweapon(Z),WeaponList),
    findall(A,claim(A,_,_,_,_),ClaimSuggOwnerList),
    findall(B,claim(_,B,_,_,_),ClaimSuggSuspectList),
    findall(C,claim(_,_,C,_,_),ClaimSuggWeaponList),
    findall(D,claim(_,_,_,D,_),ClaimSuggRoomList),
    findall(E,claim(_,_,_,_,E),ClaimNameList),
    display_facts(FactsNameList, FactsCardsList),
    display_cards(SuspectList, RoomList,WeaponList),
    display_claims(ClaimSuggOwnerList,ClaimSuggSuspectList,ClaimSuggWeaponList,ClaimSuggRoomList,ClaimNameList),
    display_possibilities.
    
display_facts([], []).
display_facts([FactsNamesH|FactsNamesT], [FactsCardsH|FactsCardsT]):-
    write("You know for a fact that "), write(FactsNamesH), write(" holds the "), write(FactsCardsH), write(" card."), put(10), put(10),
    display_facts(FactsNamesT,FactsCardsT).
    
display_claims([], [], [], [], []).
display_claims([ClaimSuggOwnerH|ClaimSuggOwnerT],[ClaimSuggSuspectH|ClaimSuggSuspectT],[ClaimSuggWeaponH|ClaimSuggWeaponT],[ClaimSuggRoomH|ClaimSuggRoomT],[ClaimNameH|ClaimNameT]):-
    write("You know that "), write(ClaimSuggOwnerH), write(" has one or more of these cards: "), write(ClaimSuggSuspectH), write(", "), write(ClaimSuggWeaponH), write(", or "), write(ClaimSuggRoomH), write(". "), write(ClaimNameH), write(" knows which one."), put(10), put(10),
    display_claims(ClaimSuggOwnerT, ClaimSuggSuspectT, ClaimSuggWeaponT, ClaimSuggRoomT, ClaimNameT).
display_cards([]).
display_cards(SL,RL,WL):-
    write("Here are all the suspects that are left: "),
    write(SL), put(10), put(10),
    write("Here are all the weapons that are left: "),
    write(WL), put(10), put(10),
    write("Here are all the rooms that are left: "),
    write(RL), put(10), put(10).

display_possibilities:-
    player_list([A,B,C,D,E,F]),
    status_list([SA,SB,SC,SD,SE,SF]),
    display_possibilities_helper([A,B,C,D,E,F],[SA,SB,SC,SD,SE,SF]).
    
display_possibilities_helper([NamesH],[StatusH]):-
    StatusH == opponent,
    write("Here are the possible cards "), write(NamesH), write(" has:"), put(10),
    findall(X, possible_cards(NamesH,X), PCList),
    write(PCList),
    put(10), put(10).
display_possibilities_helper([], []).
display_possibilities_helper([NamesH|NamesT],[StatusH|StatusT]):-
    StatusH == opponent,
    write("Here are the possible cards "), write(NamesH), write(" has:"), put(10),
    findall(X, possible_cards(NamesH,X), PCList),
    write(PCList),
    put(10), put(10),
    display_possibilities_helper(NamesT, StatusT).
display_possibilities_helper([_|NamesT],[StatusH|StatusT]):-
    StatusH == self,
    display_possibilities_helper(NamesT, StatusT).
display_possibilities_helper(_,_).

options:-
    write("Here are the options I can do for you at the command line!"), put(10),  put(10),
    write("1. display., to display all the information such as facts and claims I have stored for you!"), put(10),
    write("2. options., to display the commands I can do for you!"), put(10), 
    write("3. make_false_suggestion., this is a special option. I help you generate false suggestions to throw your opponents off!"), put(10),
    write("4. player<number>., this command is used for you to input your opponents actions and suggestions!"), put(10), put(10), put(10).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Displays information for the user to choose to make a false suggestion.
% *Special note: command function too!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 
make_false_suggestion:-
    findall(X,validsuspect(X),SL),
    findall(Y,validweapon(Y),WL),
    findall(Z,validroom(Z),RL),
    all_suspects(SL2),
    all_weapons(WL2),
    all_rooms(RL2),
    put(10), put(10), put(10),
    writeln("With the claims you know in display., choose one of the following cards you know is impossible, to make your suggestion in order to throw your opponents off. Choose wisely based on what you know about what other players know in the claims. I suggest making a suggestion with a combination of impossible cards and claims! "), put(10), put(10),
    write("Heres the list of innocent suspects, that couldnt have committed the murder: "), put(10),
    print_false_suggestion(SL2,SL), put(10), put(10),
    write("And heres the list of impossible weapons that the murderer could have used: "), put(10),
    print_false_suggestion(WL2,WL), put(10), put(10),
    write("Finally, heres the list of impossible rooms the murder could have been committed in: "), put(10), 
    print_false_suggestion(RL2,RL).

print_false_suggestion([],_).
print_false_suggestion([H],List):-
    member(H,List),
    print_false_suggestion([],List).
print_false_suggestion([H],[H]).
print_false_suggestion([H],_):-
    write(H), write(". ").
print_false_suggestion([H|T],[]):-
    write(H), write(", "),
    print_false_suggestion(T,[]).
print_false_suggestion([H|T],List):-
    member(H,List),
    print_false_suggestion(T,List).
print_false_suggestion([H|T],[H2|T2]):-
    write(H), write(", "),
    print_false_suggestion(T,[H2|T2]).
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Accusation and Suggestion functions (in player(), for self)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

make_AccOrSugg(accusation, SL, WL, RL):- 
    findall(X,validsuspect(X),SL),
    length(SL, SLen),
    SLen == 1,
    findall(Y,validweapon(Y),WL),
    length(WL, WLen),
    WLen == 1,
    findall(Z,validroom(Z),RL),
    length(RL, RLen),
    RLen == 1.    
make_AccOrSugg(suggestion,SL,WL,RL):- 
    findall(X,validsuspect(X),SL),
    findall(Y,validweapon(Y),WL),
    findall(Z,validroom(Z),RL).
    

write_AccOrSugg(accusation,[S],[W],[R]):-
    write("Hey!! I have successfully narrowed down the suspect, weapon, and room! You should make the following accusation! GO FOR IT!"), put(10), put(10),
    write("Suspect: "), write(S), put(10),
    write("Weapon: "), write(W), put(10), 
    write("Room: "), write(R), put(10).
write_AccOrSugg(suggestion,SL,WL,RL):-
    write("The following suggestions are valid suggestions you can make: "), put(10),
    write("Suspect(s): "), write(SL), put(10),
    write("Weapon(s): "), write(WL), put(10),
    write("Room(s): "), write(RL).
    
    
self_suggestion(Suspect,Weapon,Room):-
    write("Which suspect suggestion did you choose?"),
    read(Suspect), put(10),
    write("Which weapon suggestion did you choose?"),
    read(Weapon), put(10),
    write("Which room suggestion did you choose?"),
    read(Room),put(10).
    
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Opponent functions (in player(), for opponent)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    
observe(Number, Name):-
    write("Which suspect did "), write(Name), write(" suggest? "), read(SuggSuspect), put(10),
    write("Which weapon did "), write(Name), write(" suggest? "),  read(SuggWeapon), put(10),
    write("Which room did "), write(Name), write(" suggest? "),  read(SuggRoom), put(10),
    Next_opponent_number is Number + 1,
    read_other_opponents_inputs(Next_opponent_number, SuggSuspect, SuggWeapon, SuggRoom, Name).
    

read_other_opponents_inputs(Number, SuggSuspect,SuggWeapon,SuggRoom,Name):-
    Next_opponent_number is mod(Number,7),
    Next_opponent_number == 0,
    Number2 is Number + 1,
    read_other_opponents_inputs(Number2, SuggSuspect,SuggWeapon,SuggRoom,Name).
read_other_opponents_inputs(Number, SuggSuspect,SuggWeapon,SuggRoom,Name):-
    player_list([A,B,C,D,E,F]),
    find_opponent(Number, [A,B,C,D,E,F], Player_name), 
    Player_name == none,
    read_other_opponents_inputs(Number + 1, SuggSuspect,SuggWeapon,SuggRoom,Name).
read_other_opponents_inputs(Number, SuggSuspect, SuggWeapon, SuggRoom, Name):- 
    Next_opponent_number is mod(Number,7),
    player_list([A,B,C,D,E,F]),
    find_opponent(Next_opponent_number, [A,B,C,D,E,F], Next_player_name),
    Name == Next_player_name,
    opponents_reactions(opponent,0, none, SuggSuspect, SuggWeapon, SuggRoom, Name).
read_other_opponents_inputs(Number, SuggSuspect, SuggWeapon, SuggRoom, Name):-
    status_list([SA, SB, SC, SD, SE, SF]),
    Next_opponent_number is mod(Number,7),
    find_status(Next_opponent_number, [SA,SB,SC,SD,SE,SF], Next_player_status), 
    Next_player_status == self,
    show_your_cards_or_not(Next_opponent_number + 1,SuggSuspect,SuggWeapon,SuggRoom,Name).
read_other_opponents_inputs(Number, SuggSuspect, SuggWeapon, SuggRoom, Name):-
    player_list([A,B,C,D,E,F]),
    Next_opponent_number is mod(Number,7),
    find_opponent(Next_opponent_number, [A,B,C,D,E,F], Next_player_name), put(10),
    write("Did "), write(Next_player_name), write(" show a card to "), write(Name), write("? Please input yes if so, or input none if not. "),
    read(React),
    opponents_reactions(opponent,Next_opponent_number, React, SuggSuspect, SuggWeapon, SuggRoom, Name).
    
    
find_opponent(Number, [PlayerH|_], X):-
    Number == 1,
    X = PlayerH.
find_opponent(_, [PlayerH|_], _):-
    PlayerH == none.
find_opponent(Number, [_|PlayerT], X):-
    Newnumber is Number - 1,
    find_opponent(Newnumber, PlayerT, X).
    
        
make_claim(no,_,SuggSuspect,SuggWeapon,SuggRoom,Name):-
    put(10), put(10), put(10),
    write("Well, I expected "),
    write(Name),
    write(" to make an accusation, but he/she didnt... Lets move on with the next player, and when its your turn, make the suggestion they made, your accusation. Ill keep note of it too!"), put(10),
    clear_claims(SuggSuspect, SuggWeapon, SuggRoom).
make_claim(yes,SuggOwner,SuggSuspect,SuggWeapon,SuggRoom,Name):-
    % write("Who showed "), write(Name), write(" this card? "), 
    % read(SuggOwner), put(10),
    assert(claim(SuggOwner, SuggSuspect, SuggWeapon, SuggRoom, Name)),
    put(10), put(10), put(10), write(SuggOwner), write(" showed "), write(Name), write(" a card. "), put(10), put(10).


show_your_cards_or_not(_,SuggSuspect,SuggWeapon,SuggRoom,Name):-
    your_cards(List),
    my_member([SuggSuspect, SuggWeapon, SuggRoom], List),
    put(10),
    write("I would expect you to show your card to "), write(Name), write("."), put(10), put(10).
show_your_cards_or_not(Number,SuggSuspect,SuggWeapon,SuggRoom,Name):-
    Next_opponent_number is mod(Number,7),
    read_other_opponents_inputs(Next_opponent_number,SuggSuspect,SuggWeapon,SuggRoom,Name).
  
    
my_member([H], List2):- 
    member(H, List2).
my_member([H|_],List2):-
    member(H, List2).
my_member([_|T],List2):-
    my_member(T, List2).


clear_claims(SuggSuspect, SuggWeapon, SuggRoom):-
    findall(X,validsuspect(X),SuspectList),
    findall(Y,validroom(Y),RoomList),
    findall(Z,validweapon(Z),WeaponList),
    take_out_wrong_cards(SuspectList,SuggSuspect),
    take_out_wrong_cards(RoomList, SuggRoom),
    take_out_wrong_cards(WeaponList, SuggWeapon).


take_out_wrong_cards([],_).
take_out_wrong_cards([H],Sugg):-
    H == Sugg.
take_out_wrong_cards([H],_):-
    retract_single_card(H).
take_out_wrong_cards([ListH|ListT],Sugg):-
    ListH == Sugg,
    take_out_wrong_cards(ListT,Sugg).
take_out_wrong_cards([ListH|ListT], Sugg):-
    retract_single_card(ListH),
    take_out_wrong_cards(ListT, Sugg).



read_opponent_input(Number, SuggSuspect, SuggWeapon, SuggRoom, Name):-
    Next_opponent_number is mod(Number,7),
    Next_opponent_number == 0,
    read_opponent_input(Number + 1,SuggSuspect,SuggWeapon,SuggRoom,Name).
read_opponent_input(Number, SuggSuspect, SuggWeapon, SuggRoom, Name):-
    player_list([A,B,C,D,E,F]),
    find_opponent(Number, [A,B,C,D,E,F], Player_name), 
    Player_name == none,
    read_opponent_input(Number + 1, SuggSuspect,SuggWeapon,SuggRoom,Name).
read_opponent_input(Number, _, _, _, _):-
    status_list([SA, SB, SC, SD, SE, SF]),
    Next_opponent_number is mod(Number,7),
    find_status(Next_opponent_number, [SA,SB,SC,SD,SE,SF], Next_player_status), 
    Next_player_status == self.
read_opponent_input(Number, _, _, _, Name):-
    Next_opponent_number is mod(Number,7),
    player_list([A,B,C,D,E,F]),
    find_opponent(Next_opponent_number, [A,B,C,D,E,F], Player_name), 
    Player_name == Name.
read_opponent_input(Number, SuggSuspect, SuggWeapon, SuggRoom, Name):-
    player_list([A,B,C,D,E,F]),
    Next_opponent_number is mod(Number,7),
    find_opponent(Next_opponent_number, [A,B,C,D,E,F], Next_player_name), put(10),
    write("What card did "), write(Next_player_name), write(" show you? Input none if they did not show a card: "),
    read(React),
    opponents_reactions(self, Next_opponent_number, React, SuggSuspect, SuggWeapon, SuggRoom, Name).


opponents_reactions(self,Number, _, _, _, _, _):-
    Next_opponent_number is mod(Number,7), 
    Next_opponent_number == 0.
opponents_reactions(opponent,Number, React, SuggSuspect, SuggWeapon, SuggRoom, Name):-
    Next_opponent_number is mod(Number,7), 
    Next_opponent_number == 0,
    React == none,
    make_claim(no, SuggOwner, SuggSuspect, SuggWeapon, SuggRoom, Name).
opponents_reactions(self,Number, React, SuggSuspect, SuggWeapon, SuggRoom, Name):-
    React == none, 
    player_list([A,B,C,D,E,F]),
    find_opponent(Number,[A,B,C,D,E,F], Player_name),
    retract_possible_cards(Player_name, SuggSuspect),
    retract_possible_cards(Player_name,SuggWeapon),
    retract_possible_cards(Player_name,SuggRoom),
    Next_opponent_number is mod(Number + 1,7),
    read_opponent_input(Next_opponent_number, SuggSuspect, SuggWeapon, SuggRoom, Name).
opponents_reactions(opponent,Number, React, SuggSuspect, SuggWeapon, SuggRoom, Name):-
    React == none, 
    player_list([A,B,C,D,E,F]),
    find_opponent(Number,[A,B,C,D,E,F], Player_name),
    retract_possible_cards(Player_name, SuggSuspect),
    retract_possible_cards(Player_name,SuggWeapon),
    retract_possible_cards(Player_name,SuggRoom),
    Next_opponent_number is mod(Number + 1,7),
    read_other_opponents_inputs(Next_opponent_number, SuggSuspect, SuggWeapon, SuggRoom, Name).
opponents_reactions(self,Number, React, _, _, _, _):-
    retract_single_card(React),
    player_list([A,B,C,D,E,F]),
    find_opponent(Number, [A,B,C,D,E,F], Next_player_name),
    retract_possible_cards_from_all_but_one(React, Next_player_name,[A,B,C,D,E,F]),
    assert(fact(Next_player_name, React)).
opponents_reactions(opponent, Number, _, SuggSuspect, SuggWeapon, SuggRoom, Name):-
    player_list([A,B,C,D,E,F]),
    find_opponent(Number, [A,B,C,D,E,F], Next_player_name),
    make_claim(yes, Next_player_name, SuggSuspect, SuggWeapon, SuggRoom, Name).


retract_possible_cards_from_all_but_one(_, ExceptionName, [H]):-
    ExceptionName == H.
retract_possible_cards_from_all_but_one(Card, _, [H]):-
    retract_possible_cards(H,Card).
retract_possible_cards_from_all_but_one(Card, ExceptionName, [H|T]):-
    ExceptionName == H,
    retract_possible_cards_from_all_but_one(Card, ExceptionName, T).
retract_possible_cards_from_all_but_one(Card, ExceptionName, [H|T]):-
    retract_possible_cards(H,Card),
    retract_possible_cards_from_all_but_one(Card, ExceptionName, T).
    
    
retract_possible_cards(Player_name,X):-
    findall(X, possible_cards(Player_name, X), List),
    retract_possible_cards_helper(List, Player_name, X).


retract_possible_cards_helper([], _,_).
retract_possible_cards_helper([H], Player_name,X):-
    H == X,
    retract(possible_cards(Player_name,H)).
retract_possible_cards_helper([], _,_).
retract_possible_cards_helper([H|_], Player_name,X):-
    H == X,
    retract(possible_cards(Player_name,H)).
retract_possible_cards_helper([_|T], Player_name,X):-
    retract_possible_cards_helper(T, Player_name,X).
    
    
    
find_status(Number, [StatusH|_], X):-
    Number == 1,
    X = StatusH.
find_status(_, [StatusH|_], _):-
    StatusH == none.
find_status(Number, [_|StatusT], X):-
    Newnumber is Number - 1,
    find_status(Newnumber, StatusT, X).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Clauses to assert/retract.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

all_suspects([white,mustard,peacock,green,scarlet,plum]).
all_weapons([rope,candlestick,knife,revolver,leadpipe,wrench]).
all_rooms([hall,lounge,diningroom,kitchen,ballroom,conservatory,billiardroom,library,study]).
    
validsuspect(scarlet).
validsuspect(mustard).
validsuspect(green).
validsuspect(peacock).
validsuspect(white).
validsuspect(plum).

validweapon(knife).
validweapon(candlestick).
validweapon(revolver).
validweapon(rope).
validweapon(leadpipe).
validweapon(wrench).

validroom(hall).
validroom(lounge).
validroom(diningroom).
validroom(kitchen).
validroom(ballroom).
validroom(conservatory).
validroom(billiardroom).
validroom(library).
validroom(study).

player(scarlet).
player(mustard).
player(green).
player(peacock).
player(white).
player(plum).
player(none).