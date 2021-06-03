/*****************************************************************************

		Copyright (c) My Company

 Project:  Checkers
 FileName: CHECKERS.INC
 Purpose:  Project's global declarations
 Written by: ZhbanovVA
 Comments:
*****************************************************************************/

constants
%BEGIN_CONST Project configuration constants, Code automatically updated!
  use_3dctrl = 1
  use_dlgpack = 1
%END_CONST

include "vpi.con"
include "vpi.dom"
include "vpi.pre"


/*****************************************************************************
			User's Declarations
*****************************************************************************/
global domains
  DB_SELECTOR = browselist_db	% For treebrowser tool
  FILE = fileselector1; fileselector2 % To be edited

include "checkers.pre"

include "vpitools.dom"
include "vpitools.pre"
