/*****************************************************************************

		Copyright (c) My Company

 Project:  CHECKERS
 FileName: CHECKERS.PRO
 Purpose: No description
 Written by: ZhbanovVA
 Comments:
******************************************************************************/

include "checkers.inc"
include "checkers.con"
include "hlptopic.con"

/***************************************************************************
		????????
***************************************************************************/
constants
  helpfile="help.txt"
  gamefile="regulations.txt"
  colorsfile="colors.txt"
  
facts-parameters
  get(string,integer)
predicates
  set(string,integer)
clauses
  set(Name,Value):-
    retract(get(Name,_),parameters),!,
    asserta(get(Name,Value),parameters),!;
    asserta(get(Name,Value),parameters),!.

/***************************************************************************
		???????
***************************************************************************/
domains
  points=pnt*
predicates
  size(points,integer)
  
  min(integer,integer,integer)
  max(integer,integer,integer)
  
  push_in_rect(pnt,pnt,pnt)
clauses
  size([],0):-!.
  size([_|T],S):-!,size(T,N),S=N+1.
  
  min(L,R,V):-L<R,!,V=L;!,V=R.
  max(L,R,V):-L>R,!,V=L;!,V=R.
  
  /*
    ????????? ???? ? ???? ??? ????? ?????? ???????????? ????????????
  */
  push_in_rect(pnt(RX,RY),pnt(PX,PY),pnt(CX,CY)):-
    RX/PX<RY/PY,!,CX=PX*RX/PX,CY=PY*RX/PX;
    		!,CX=PX*RY/PY,CY=PY*RY/PY.

/***************************************************************************
		???????? ????????? ????
***************************************************************************/
constants
  fieldsize=8
  black=1
  white=0
  noking=0
  king=1
  void=0
  dirs=[pnt(-1,1),pnt(1,1),pnt(-1,-1),pnt(1,-1)]
  
facts-route
  route(integer,pnt,pnt,points)

facts-field
  field(pnt,integer,integer)
  
predicates
  dir(integer,integer,points)
clauses
  dir(black,  king,dirs):-!.
  dir(white,  king,dirs):-!.
  dir(black,noking,[pnt(-1,1),pnt(1,1)                     ]):-!.
  dir(white,noking,[                   pnt(-1,-1),pnt(1,-1)]):-!.
  
predicates

  /*
    ?????????????? ????????? ???? ? ?????????
  */
  refresh()
  refresh(integer,integer,integer)
  
  /*
    ??????? ????? ??????????? ? ??????? ????????
  */
  kill(points)
  
  /*
    ?????????? ????????? ???????? ??? ????? ????????? ?????
  */
  generate_routes(integer,integer)
  generate_routes_attack(integer,integer)
  
  get_first_routes(integer,pnt,integer)
  get_first_routes_(integer,pnt,integer)
  get_first_routes_attack(integer,pnt,integer)
  
  get_second_routes(integer,pnt,integer)
  
  get_attack_routes(integer,pnt,pnt,points,integer,integer,integer,points)
  get_attack_routes1(integer,pnt,pnt,points,integer,integer,integer,points)
  
  get_noattack_routes(integer,pnt,points,integer,integer)
  
  get_routes_king(integer,pnt,pnt,pnt,integer,integer,integer,points)
  get_routes_king1(integer,pnt,pnt,pnt,integer,integer,integer,points)
  
  /*
    ?????????? ????? ?? ????? ?????? ? ??????
  */
  swap(pnt,pnt)
  
  /*
    ????????? ??? ??????? ??????????? ????
  */
  is_field(integer,integer)
  
  /*
    ??????????? ?????? ? ????? ???? ??? ????
  */
  to_king(integer,integer,integer,integer)
  
  /*
    ???????? ?? ????? (???? ???? ????? ?? ????????????? ? ????? ???)
  */
  is_draw(points)
  
clauses
  refresh():-
    retractall(field(_,_,_),field),
    refresh(0,black,24),
    Y=fieldsize-3,
    refresh(40,white,64).

  refresh(Num,Value,Max):-Max<=Num,!.
  refresh(Num,Value,Max):-
    X=Num mod fieldsize,
    Y=Num div fieldsize,
    X mod 2 <> Y mod 2,
    assert(field(pnt(X,Y),Value,noking),field),fail;
    N=Num+1,!,
    refresh(N,Value,Max).

  kill([]):-!.
  kill([H|T]):-retract(field(H,_,_),field),!,kill(T).
  
  get_first_routes(ID,Pos,Depth):-
    field(Pos,C,K),Enemy=(C+1) mod 2,
    generate_routes_attack(ID,C),
    route(ID,_,_,[H|T]),!,
    retractall(route(ID,_,_,_),route),
    get_first_routes_attack(ID,Pos,Depth),
  !;
    field(Pos,C,K),Enemy=(C+1) mod 2,
    retractall(route(ID,_,_,_),route),
    get_first_routes_(ID,Pos,ID),
  !.
  
  generate_routes(Depth,Color):-
    field(P,Color,_),
    get_first_routes_(Depth,P,18),fail;!.
    
  generate_routes_attack(Depth,Color):-
    field(P,Color,_),
    get_first_routes_attack(Depth,P,18),fail;!.
    
  get_first_routes_(ID,pnt(X,Y),Depth):-
    field(pnt(X,Y),C,K),Enemy=(C+1) mod 2,
    dir(C,K,List),get_noattack_routes(ID,pnt(X,Y),List,K,Enemy),
  !.
  
  get_first_routes_attack(ID,pnt(X,Y),Depth):-
    field(pnt(X,Y),C,K),Enemy=(C+1) mod 2,
    get_attack_routes(ID,pnt(X,Y),pnt(X,Y),dirs,K,Enemy,Depth,[]),
  !.
  
  get_second_routes(ID,pnt(X,Y),Depth):-
    field(pnt(X,Y),C,K),Enemy=(C+1) mod 2,
    get_attack_routes(ID,pnt(X,Y),pnt(X,Y),dirs,C,Enemy,Depth,[]),
  !;!.
  
  get_attack_routes(ID,Begin,pnt(X,Y),[],_,Enemy,Depth,List):-!.
  get_attack_routes(ID,Begin,pnt(X,Y),[pnt(DX,DY)|T],noking,Enemy,Depth,List):-
    get_attack_routes(ID,Begin,pnt(X,Y),T,noking,Enemy,Depth,List),
    X1=X+DX,Y1=Y+DY,is_field(X1,Y1),
    field(pnt(X1,Y1),Enemy,_),!,
    retract(field(pnt(X1,Y1),Enemy,K),field),!,
    get_attack_routes1(ID,Begin,pnt(X,Y),[pnt(DX,DY)|T],noking,Enemy,Depth,List),
    asserta(field(pnt(X1,Y1),Enemy,K),field),
  !;!.
  get_attack_routes(ID,Begin,pnt(X,Y),[pnt(DX,DY)|T],king,Enemy,Depth,List):-
     get_attack_routes(ID,Begin,pnt(X,Y),T,king,Enemy,Depth,List),
     get_routes_king(ID,Begin,pnt(X,Y),pnt(DX,DY),Enemy,0,Depth,List),
  !;!.
  
  get_attack_routes1(ID,Begin,pnt(X,Y),[pnt(DX,DY)|T],noking,Enemy,Depth,List):-
    X1=X+DX,Y1=Y+DY,
    X2=X1+DX,Y2=Y1+DY,is_field(X2,Y2),
    not(field(pnt(X2,Y2),_,_)),
    L=[pnt(X1,Y1)|List],
    asserta(route(ID,Begin,pnt(X2,Y2),L),route),
    0<Depth,D=Depth-1,get_attack_routes(ID,Begin,pnt(X2,Y2),dirs,noking,Enemy,D,L),
  !;!.
  
  get_noattack_routes(ID,pnt(X,Y),[],_,Enemy):-!.
  get_noattack_routes(ID,pnt(X,Y),[pnt(DX,DY)|T],noking,Enemy):-
    get_noattack_routes(ID,pnt(X,Y),T,noking,Enemy),
    X1=X+DX,Y1=Y+DY,is_field(X1,Y1),
    not(field(pnt(X1,Y1),_,_)),
    asserta(route(ID,pnt(X,Y),pnt(X1,Y1),[]),route),
  !;!.
  get_noattack_routes(ID,pnt(X,Y),[pnt(DX,DY)|T],king,Enemy):-
     get_noattack_routes(ID,pnt(X,Y),T,king,Enemy),
     get_routes_king(ID,pnt(X,Y),pnt(X,Y),pnt(DX,DY),Enemy,1,0,[]),
  !;!.
  
  get_routes_king(ID,Begin,pnt(X,Y),pnt(DX,DY),Enemy,Attack,Depth,L):-
    X1=X+DX,Y1=Y+DY,is_field(X1,Y1),
    field(pnt(X1,Y1),Enemy,_),!,
    retract(field(pnt(X1,Y1),Enemy,K),field),!,
    get_routes_king1(ID,Begin,pnt(X,Y),pnt(DX,DY),Enemy,Attack,Depth,L),
    asserta(field(pnt(X1,Y1),Enemy,K),field),
  !;
    X1=X+DX,Y1=Y+DY,is_field(X1,Y1),
    not(field(pnt(X1,Y1),_,_)),
    get_routes_king(ID,Begin,pnt(X1,Y1),pnt(DX,DY),Enemy,Attack,Depth,L),
    Attack<>0,
    asserta(route(ID,Begin,pnt(X1,Y1),L),route),
  !;!.
  
  get_routes_king1(ID,Begin,pnt(X,Y),pnt(DX,DY),Enemy,Attack,Depth,L):-
    X1=X+DX,Y1=Y+DY,
    X2=X1+DX,Y2=Y1+DY,is_field(X2,Y2),
    not(field(pnt(X2,Y2),_,_)),
    List=[pnt(X1,Y1)|L],
    asserta(route(ID,Begin,pnt(X2,Y2),List),route),
    get_routes_king(ID,Begin,pnt(X2,Y2),pnt(DX,DY),Enemy,1,Depth,List),
    0<Depth,D=Depth-1,get_attack_routes(ID,Begin,pnt(X2,Y2),dirs,king,Enemy,D,List),
  !;!.
  
  swap(pnt(CX,CY),pnt(X,Y)):-!,
    retract(field(pnt(CX,CY),V,P),field),!,
    to_king(Y,V,P,K),
    asserta(field(pnt(X,Y),V,K),field).
    
  is_field(X,Y):-!,0<=X,X<fieldsize,0<=Y,Y<fieldsize.
  
  to_king(Y,X,P,K):-Y=X*(fieldsize-1),!,K=king;!,K=P.
  
  is_draw([]):-get(draw,B),Bn=B+1,set(draw,Bn),Bn=20,set(move,0),dlg_Note("?????","?? ?? ?? ?????? ??? ????????");!.
  is_draw([H|T]):-set(draw,0).
  
/***************************************************************************
		???
***************************************************************************/
domains
  broute=broute(pnt,pnt,points)

facts-bestroute
  bestroute(broute,integer)

predicates

  /*
    ?????? ??? ????
  */
  find_and_make_computer_move()
  
  /*
    ????????? ????????? ????
  */
  estimate_route(integer,integer)
  estimate_route(broute,integer,integer)
  estimate_route(integer,integer,integer,integer)
  
  
  /*
    ??????????? ?????? ???? ?? ?????? ?????????? ?????
    ???????????? ??? ?????????? ??????? ??????? ??? 
    ??? ?????????? ????? (????? ???-?? ???????)
  */
  estimate_static(integer,integer,integer)
  estimate_static(integer)
  
  /*
    ??????? ?? ????????? ???????
  */
  deepening(integer,integer,integer)
  
  /*
    ?????? ??? ??? ????, ????????? ? ??
  */
  best_route(broute,integer)
    
  /*
    ???????? ?????? ???, ????? ??????? / ???????? ? ??????????? ?? ??????
  */
  best_route(integer,integer,integer,integer)
  
  /*
    ?????????? ???? ??? ?????????
  */
  generate_computer_move(integer,integer)
  
clauses
  find_and_make_computer_move():-
    retractall(route(_,_,_,_),route),
    retractall(bestroute(_,_),bestroute),
    asserta(bestroute(broute(pnt(-1,-1),pnt(-1,-1),[]),-10000),bestroute),
    get(depth,Depth),
    generate_computer_move(Depth,black),
    estimate_route(Depth,black),
    bestroute(broute(pnt(CX,CY),pnt(X,Y),Points),Score),
    Score<>-10000,
    is_draw(Points),kill(Points),swap(pnt(CX,CY),pnt(X,Y)),
  !.
  
  estimate_route(Depth,Color):-
    retract(route(Depth,P,End,Points),route),!,
    estimate_route(broute(P,End,Points),Depth,V),
    best_route(broute(P,End,Points),V),
    estimate_route(Depth,Color),
  !;!.

  estimate_route(broute(pnt(BX,BY),pnt(EX,EY),[]),Depth,Value):-!,
    retract(field(pnt(BX,BY),V,P),field),!,to_king(EY,V,P,K),
    asserta(field(pnt(EX,EY),V,K),field),
    Enemy=(V+1)mod 2,estimate_static(Enemy,Depth,Value),
    retract(field(pnt(EX,EY),V,K),field),!,
    asserta(field(pnt(BX,BY),V,P),field),
  !.
  estimate_route(broute(P1,P2,[pnt(X,Y)|T]),Depth,Value):-!,
    retract(field(pnt(X,Y),C,K),field),!,
    estimate_route(broute(P1,P2,T),Depth,Value),
    asserta(field(pnt(X,Y),C,K),field),
  !.
  
  estimate_route(Depth,Color,Best,Value):-
    retract(route(Depth,P,End,Points),route),!,
    estimate_route(broute(P,End,Points),Depth,V),
    best_route(Color,Best,V,B),!,
    estimate_route(Depth,Color,B,Value),
  !;Value=Best,!.
  
  estimate_static(Enemy,Depth,Value):-
    0<Depth,D=Depth-1,field(_,Enemy,_),!,
    deepening(D,Enemy,Value),
  !;
    estimate_static(Value),
  !.
  
  estimate_static(Value):-
    findall(L1,field(L1,black,noking),List1),!,size(List1,BN),
    findall(L2,field(L2,black,  king),List2),!,size(List2,BK),
    findall(L3,field(L3,white,noking),List3),!,size(List3,WN),
    findall(L4,field(L4,white,  king),List4),!,size(List4,WK),
    Value=BN+3*BK-WN-3*WK,
  !.
      
  deepening(Depth,Color,Value):-
    Best=10000-Color*20000,
    generate_computer_move(Depth,Color),
    estimate_route(Depth,Color,Best,Value),
  !.
  
  best_route(BR,Current):-
    bestroute(_,Best),
    Best<Current,
    retract(bestroute(_,_),bestroute),!,
    asserta(bestroute(BR,Current),bestroute),
  !;!.
  
  best_route(black,Best,Current,Value):-max(Best,Current,Value),!.
  best_route(white,Best,Current,Value):-min(Best,Current,Value),!.
  
  
  generate_computer_move(Depth,Color):-
    generate_routes_attack(Depth,Color),
    not(route(Depth,_,_,_)),
    generate_routes(Depth,Color),
  !;!.
  
/***************************************************************************
		?????
***************************************************************************/
predicates

  /*
    ???????????? ????? ???????????? ?? ????
  */
  click(pnt)
  
  /*
    ?????????? ????? ????????????? ???????? ???? ???
  */
  end_move()
  
clauses
  click(pnt(X,Y)):-
    get(move,1),
    field(pnt(X,Y),white,K),
    set(selected_x,X),set(selected_y,Y),
    retractall(route(_,_,_,_),route),
    get_first_routes(-2,pnt(X,Y),0),
  !;
    route(-2,pnt(CX,CY),pnt(X,Y),[]),
    swap(pnt(CX,CY),pnt(X,Y)),
    retractall(route(_,_,_,_),route),
    end_move(),
  !;
    route(-2,pnt(CX,CY),pnt(X,Y),Points),
    swap(pnt(CX,CY),pnt(X,Y)),
    is_draw(Points),
    kill(Points),
    set(move,2),set(selected_x,X),set(selected_y,Y),
    retractall(route(_,_,_,_),route),
    get_second_routes(-2,pnt(X,Y),0),
    end_move(),
  !;
  !.
  
  end_move():-route(-2,_,_,_),!.
  end_move():-!,set(move,-1).
  

/***************************************************************************
		?????????
***************************************************************************/
constants
  red_brush=brush(pat_Solid,0x0000FF)
  green_brush=brush(pat_Solid,0x00FF00)
  blue_brush=brush(pat_Solid,0xFF0000)
  
facts-brushs
  mbrush(string,brush)
clauses
  mbrush(white_brush,brush(pat_Solid,0xBBBBBB)).
  mbrush(white_king_brush,brush(pat_Solid,0xFFFFFF)).
  mbrush(black_brush,brush(pat_Solid,0x444444)).
  mbrush(black_king_brush,brush(pat_Solid,0x000000)).
  mbrush(field_white_brush,brush(pat_Solid,0x00CCFF)).
  mbrush(field_black_brush,brush(pat_Solid,0x006699)).
  
predicates  
  
  /*
    ?????? ????
  */
  draw_field(window,pnt)
    
  /*
    ?????? ?????
  */
  draw_matrix(window,integer,integer)
  get_field_brush(pnt,brush)
    
  /*
    ?????? ?????
  */
  draw_figures(window,integer)
  get_figure_brush(integer,integer,brush)
    
  /*
    ????????? ????????? ?????
  */
  draw_routes(window,integer)
  
clauses

  draw_field(_Win,pnt(W,H)):-
    Size=W/fieldsize,
    draw_matrix(_Win,0,Size),
    draw_figures(_Win,Size),
    get(selected_x,X),get(selected_y,Y),
    CX=X*Size,CY=Y*Size,
    XS=CX+10,YS=CY+10,
    win_SetBrush(_Win,red_brush),
    draw_Ellipse(_Win,rct(CX,CY,XS,YS)),
    draw_routes(_Win,Size),
  !.
  
  draw_matrix(_Win,Num,Size):-fieldsize*fieldsize<=Num,!.
  draw_matrix(_Win,Num,Size):-
    X=Num mod fieldsize,
    Y=Num div fieldsize,
    get_field_brush(pnt(X,Y),Brush),!,
    win_SetBrush(_Win,Brush),
    CX=X*Size,CY=Y*Size,SX=CX+Size,SY=CY+Size,
    draw_Rect(_Win,rct(CX,CY,SX,SY)),
    !,N=Num+1,draw_matrix(_Win,N,Size).
    
  get_field_brush(pnt(X,Y),Brush):-
    X mod 2 <> Y mod 2,mbrush(field_black_brush,Brush),!;
                       mbrush(field_white_brush,Brush),!.
  
  draw_figures(_Win,Size):-
    field(pnt(X,Y),Color,King),
    get_figure_brush(Color,King,Brush),
    win_SetBrush(_Win,Brush),
    CX=X*Size,CY=Y*Size,SX=CX+Size,SY=CY+Size,
    draw_Ellipse(_Win,rct(CX,CY,SX,SY)),fail,
  !;!.
  
  get_figure_brush(white,noking,Brush):-!,mbrush(white_brush,     Brush),!.
  get_figure_brush(white,  king,Brush):-!,mbrush(white_king_brush,Brush),!.
  get_figure_brush(black,noking,Brush):-!,mbrush(black_brush,     Brush),!.
  get_figure_brush(black,  king,Brush):-!,mbrush(black_king_brush,Brush),!.
  
  draw_routes(_Win,Size):-
    win_SetBrush(_Win,green_brush),
    route(-2,_,pnt(X,Y),_),
    CX=X*Size,CY=Y*Size,
    XS=CX+10,YS=CY+10,
    draw_Ellipse(_Win,rct(CX,CY,XS,YS)),fail,
  !;!.
    

%BEGIN_WIN Task Window
/***************************************************************************
		Event handling for Task Window
***************************************************************************/
predicates
  task_win_eh : EHANDLER

constants
%BEGIN Task Window, CreateParms, 11:25:47-6.5.2021, Code automatically updated!
  task_win_Flags = [wsf_SizeBorder,wsf_TitleBar,wsf_Close,wsf_Minimize,wsf_ClipSiblings,wsf_Maximize,wsf_ClipChildren]
  task_win_Menu  = res_menu(id_menu)
  task_win_Title = "?????"
  task_win_Help  = idh_contents
%END Task Window, CreateParms

clauses
%BEGIN Task Window, e_Create
  task_win_eh(_Win,e_Create(_),0):-!,
%BEGIN Task Window, InitControls, 11:25:47-6.5.2021, Code automatically updated!
%END Task Window, InitControls
    win_Move(_Win,rct(400,100,1300,1000)),
    refresh(),
    set(move,1),set(depth,3),
    timer_Set(_Win,100),
    existfile(colorsfile),
    retractall(mbrush(_,_),brushs),
    consult(colorsfile,brushs),
  !.
%END Task Window, e_Create

%MARK Task Window, new events

%BEGIN Task Window, idr_setting
  task_win_eh(_Win,e_Menu(idr_setting,_ShiftCtlAlt),0):-
    dlg_setting_Create(_Win),
  !.
%END Task Window, idr_setting

%BEGIN Task Window, idr_new_game
  task_win_eh(_Win,e_Menu(idr_new_game,_ShiftCtlAlt),0):-
    refresh(),
    set(move,1),
    win_Invalidate(_Win),
  !.
%END Task Window, idr_new_game

%BEGIN Task Window, idr_help
  task_win_eh(_Win,e_Menu(idr_help,_ShiftCtlAlt),0):-
    dlg_help_Create(_Win),
  !.
%END Task Window, idr_help

%BEGIN Task Window, e_Timer
  
  /*
    ? ??????? ??????????? ????? ???????????? ???????? ???? ??? ? ?????? ??? ??????????
    ????? ??????? ????????? ????? ????? ??????
  */
  task_win_eh(_Win,e_Timer(_TimerId),0):-
    get(move,-1),find_and_make_computer_move(),win_Invalidate(_Win),not(get(move,0)),set(move,-3),
    generate_routes(-2,white),
    not(route(_,_,_,_)),set(move,0),dlg_Note("?????????","? ??? ?? ???????? ?????"),
  !;
    get(move,-3),retractall(route(_,_,_,_),route),set(move,1),
  !;
    get(move,-1),set(move,0),dlg_Note("??????","? ?????????? ?? ???????? ?????"),
  !.
	
%END Task Window, e_Timer

%BEGIN Task Window, e_MouseUp
  task_win_eh(_Win,e_MouseUp(pnt(X,Y),_ShiftCtlAlt,_Button),0):-
    get(win_width,Width),get(win_height,Height),
    push_in_rect(pnt(Width,Height),pnt(1,1),pnt(CX,CY)),
    X<CX,Y<CY,
        
    /*
      ??????? ??????? ????????? ? ?????????? ????
    */
    XF=trunc(X/CX*fieldsize),YF=trunc(Y/CY*fieldsize),
    
    click(pnt(XF,YF)),
    win_Invalidate(_Win),
  !.
%END Task Window, e_MouseUp

%BEGIN Task Window, e_Update
  task_win_eh(_Win,e_Update(_),0):-
    get(win_width,Width),get(win_height,Height),
    push_in_rect(pnt(Width,Height),pnt(1,1),PT),
    draw_field(_Win,PT),
  !.
%END Task Window, e_Update

%BEGIN Task Window, e_Size
  task_win_eh(_Win,e_Size(_Width,_Height),0):-
    set(win_width,_Width),set(win_height,_Height),
    win_Invalidate(_Win),
  !.
%END Task Window, e_Size

%END_WIN Task Window

%BEGIN_DLG Help
/**************************************************************************
		???? ??????
**************************************************************************/
constants
%BEGIN Help, CreateParms, 11:45:45-6.5.2021, Code automatically updated!
  dlg_help_ResID = idd_help
  dlg_help_DlgType = wd_Modal
  dlg_help_Help = idh_contents
%END Help, CreateParms

predicates
  dlg_help_eh : EHANDLER

clauses
  dlg_help_Create(Parent):-
	win_CreateResDialog(Parent,dlg_help_DlgType,dlg_help_ResID,dlg_help_eh,0).

%MARK Help, new events

%BEGIN Help, idc_game _CtlInfo
  dlg_help_eh(_Win,e_Control(idc_game,_CtrlType,_CtrlWin,_CtlInfo),0):-
    existfile(gamefile),
    file_str(gamefile,Text),
    Handle=win_GetCtlHandle(_Win,idc_text),
    win_SetText(Handle,Text),
  !;
    dlg_Error("??????","?? ??????? ??????? ???? ? ?????????"),
  !.
%END Help, idc_game _CtlInfo

%BEGIN Help, idc_api _CtlInfo
  dlg_help_eh(_Win,e_Control(idc_api,_CtrlType,_CtrlWin,_CtlInfo),0):-
    existfile(helpfile),
    file_str(helpfile,Text),
    Handle=win_GetCtlHandle(_Win,idc_text),
    win_SetText(Handle,Text),
  !;
    dlg_Error("??????","?? ??????? ??????? ???? ? ?????????"),
  !.
%END Help, idc_api _CtlInfo

%BEGIN Help, e_Create
  dlg_help_eh(_Win,e_Create(_CreationData),0):-
    win_SendEvent(_Win,e_Control(idc_api,0,_Win,getfocus())),
  !.
%END Help, e_Create

  dlg_help_eh(_,_,_):-!,fail.

%END_DLG Help

/**************************************************************************
		????? ?????
**************************************************************************/
predicates
  control_brush(integer,brush)
  control_idbrush(integer,string)
  
clauses
  control_brush(CtlId,Brush):-
    free(Brush),!,
    control_idbrush(CtlId,BrushId),!,
    mbrush(BrushId,Brush),
  !;
    bound(Brush),
    control_idbrush(CtlId,BrushId),!,
    retract(mbrush(BrushId,_),brushs),!,
    assert(mbrush(BrushId,Brush),brushs),
  !.
    
  control_idbrush(idc_white,white_brush):-!.
  control_idbrush(idc_white_king,white_king_brush):-!.
  control_idbrush(idc_black,black_brush):-!.
  control_idbrush(idc_black_king,black_king_brush):-!.
  control_idbrush(idc_field_white,field_white_brush):-!.
  control_idbrush(idc_field_black,field_black_brush):-!.
  
%BEGIN_DLG Setting
/**************************************************************************
	???? ????????
**************************************************************************/
constants

%BEGIN Setting, CreateParms, 21:51:06-17.5.2021, Code automatically updated!
  dlg_setting_ResID = idd_setting
  dlg_setting_DlgType = wd_Modal
  dlg_setting_Help = idh_contents
%END Setting, CreateParms

predicates
  dlg_setting_eh : EHANDLER
  dlg_setting_handle_answer(INTEGER EndButton,DIALOG_VAL_LIST)
  dlg_setting_update(DIALOG_VAL_LIST)

clauses
  dlg_setting_Create(Parent):-
%MARK Setting, new variables
	dialog_CreateModal(Parent,dlg_setting_ResID,"",
  		[
%BEGIN Setting, ControlList, 21:51:06-17.5.2021, Code automatically updated!
		df(idc_complexity,listbutton(["?????","?????????","??????","??????"],0),nopr)
%END Setting, ControlList
		],
		dlg_setting_eh,0,VALLIST,ANSWER),
	dlg_setting_handle_answer(ANSWER,VALLIST).

  dlg_setting_handle_answer(idc_ok,VALLIST):-!,
	dlg_setting_update(VALLIST).
  dlg_setting_handle_answer(idc_cancel,_):-!.  % Handle Esc and Cancel here
  dlg_setting_handle_answer(_,_):-
	errorexit().

  dlg_setting_update(_VALLIST):-
%BEGIN Setting, Update controls, 21:51:06-17.5.2021, Code automatically updated!
	dialog_VLGetListButton(idc_complexity,_VALLIST,_IDC_COMPLEXITY_ITEMLIST,_IDC_COMPLEXITY_SELECT),
%END Setting, Update controls
	true.

%MARK Setting, new events

%BEGIN Setting, e_Destroy
  dlg_setting_eh(_Win,e_Destroy,0):-
    save(colorsfile,brushs),
    H=win_GetParent(_Win),
    win_Invalidate(H),
  !.
%END Setting, e_Destroy

%BEGIN Setting, e_Create
  dlg_setting_eh(_Win,e_Create(_CreationData),0):-
    H=win_GetCtlHandle(_Win,idc_complexity),
    get(depth,Depth),
    lbox_SetSel(H,Depth,1),
  !.
%END Setting, e_Create

%BEGIN Setting, idc_complexity selchanged
  dlg_setting_eh(_Win,e_Control(idc_complexity,_CtrlType,_CtrlWin,selchanged),0):-
    lbox_GetSel(_CtrlWin,_,L),
    L=[Depth],
    set(depth,Depth),
  !.
%END Setting, idc_complexity selchanged

%BEGIN Setting, idc_white _CtlInfo
  dlg_setting_eh(_Win,e_Control(_CtlId,wc_PushButton,_CtrlWin,_CtlInfo),0):-
    Color=dlg_ChooseColor(_Win,0),
    Color<>0,
    control_brush(_CtlId,brush(pat_Solid,Color)),
    win_Invalidate(_Win),
  !.
%END Setting, idc_white _CtlInfo

%BEGIN Setting, e_OwnerDraw
  dlg_setting_eh(_Win,e_OwnerDraw(_CtlType,_CtlId,_ItemId,_ItemAction,_ItemState,_CtlWin,_RectItem,_ItemData),0):-
    control_brush(_CtlId,Brush),
    win_SetBrush(_CtlWin,Brush),
    draw_Rect(_CtlWin,_RectItem),
  !.
%END Setting, e_OwnerDraw

  dlg_setting_eh(_,_,_):-!,fail.

%END_DLG Setting

/***************************************************************************
			????? ?????
***************************************************************************/
goal
  vpi_Init(task_win_Flags,task_win_eh,task_win_Menu,task_win_Title,task_win_Title).