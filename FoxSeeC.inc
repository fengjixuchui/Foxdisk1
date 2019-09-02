;---------------------------------------- 配色方案开始 -----------------------------------------
;缺省的配色方案
BackGround_COLOR				  DW  BLUE					        										;背景色
;windows
WND_Caption_COLOR				  DW  DEEPBLUE																;窗口标题栏的颜色
WND_LightShadow_COLOR		  DW  WHITE																;窗体靠近光源处的亮色阴影
WND_GrayShadow_COLOR		  DW  LIGHTBLACK														;窗体亚暗色阴影
WND_DarkShadow_COLOR		  DW  DARKBLACK														;窗体暗色阴影
WND_FRAME_CapText_COLOR	  DW  WHITE															;基本框架的标题栏文字的颜色（比如显示内外网选择的框架）
;editbox
EditBox_BG_COLOR				  DW  WHITE																		;编辑框的背景颜色
EditBox_DarkShadow_COLOR  DW  DARKBLACK												;编辑框暗色阴影
EditBox_LightShadow_COLOR DW  LIGHTBLACK											;编辑框亚暗色阴影
;button
BUTTON_Shadow_COLOR			  LABEL WORD 														;按钮的背景框颜色
SEL_BUTTON_NShadow_COLOR  DW  WHITE																;选中的按钮内阴影
SEL_BUTTON_WShadow_COLOR  DW  DARKBLACK												;选中的按钮外阴影
;Part managment
PM_CaptionText_COLOR		  DW  WHITE																;分区管理子系统的标题（文字）颜色
PM_WND_BK_COLOR					  DW  LIGHTGRAY																	;分区管理子系统窗体的背景色
PM_StaticText_COLOR			  DW  GREEN;WHITE																	;分区管理子系统静态显示文字颜色（如分区显示要用的字符串）
PM_ActiveFlag_COLOR			  DW  RED																		;分区管理子系统中活动分区的显示颜色（'A'）
PM_FunButtonText_COLOR	  DW  RED																;分区管理子系统功能按钮的文字颜色
PM_EditZoneText_COLOR		  DW  GREEN																;分区管理子系统编辑区的文字颜色
PM_CURSOR_COLOR					  DW  DARKBLACK																	;分区管理子系统中光标的颜色
PM_PartMessage_COLOR		  DW  BLACK																;分区管理子系统显示分区信息的文字颜色
;内外网选择界面
NWBUT_LightShadow_COLOR		  DW  WHITE																;按钮靠近光源处的亮色阴影
NWBUT_GrayShadow_COLOR		  DW  LIGHTBLACK													;按钮亚暗色阴影
NWBUT_DarkShadow_COLOR		  DW  DARKBLACK														;按钮暗色阴影
NW_STR_WAI								  DW  RED
NW_STR_NEI								  DW  GREEN
DEFAULT_MATCH_COLOREND		  DW  0AA55H
