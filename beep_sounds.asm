	list      p=12f683
	#include <p12f683.inc>

	errorlevel  -302

;	__CONFIG   _CP_OFF & _CPD_OFF & _BODEN_OFF & _MCLRE_OFF & _WDT_OFF & _PWRTE_ON & _INTRC_OSC_NOCLKOUT
	__CONFIG   _CP_OFF & _CPD_OFF & _BOREN_OFF & _MCLRE_OFF & _WDT_OFF & _PWRTE_ON & _INTRC_OSC_NOCLKOUT

#define		TCNT50MS	d'61'	; 割り込みによる50mS計測のための定数
#define		TCNT1S		d'20'	; 1S = 50ms X 20
#define		TIME_GO		d'181'	; 3分(引いてゼロになった瞬間に音が鳴るので+1しておく)
#define		TIME_OUT	d'60'	; 1分以上ブザーなっても手遅れ

#define		BEEP_P		GPIO,2	;ビープ用スピーカポート
#define		PUSH_SW		GPIO,5	;プッシュスイッチ用ポート
#define		LED_P		GPIO,1	;動作確認LED用ポート

;***** VARIABLE DEFINITIONS
w_temp			EQU		0x20		;割り込みハンドラ用 
status_temp		EQU		0x21		;割り込みハンドラ用
CNT1			EQU		0x22		;ディレイルーチン用

;;; ディレイルーチン用
;;; 全体の処理時間は以下で計算
;;; CNT_N_100ms * (CNT_100ms * 2 * (256*CNT_256 + CNT_M))
;;;                                ^^^^^^^^^^^^^^^^^^^^^ 周波数/2
;;;                           ^^^                        周波数 ON/OFF で２回分
;;;               ^^^^^^^^^^                             100ms用カウンタ
;;; ^^^^^^^^^^^                                          100ms*N回
CNT_N_100ms		EQU		0x23		;ディレイルーチン用
CNT_100ms		EQU		0x24		;ディレイルーチン用
CNT_256			EQU		0x25		;ディレイルーチン用 256*N+M のN
CNT_M			EQU		0x26		;ディレイルーチン用 256*N+M のM
CNT_N			EQU		0x27		;ディレイルーチン用 Ncycle 待ち用
WORK_CNT_100ms	EQU		0x28		;ディレイルーチン用
WORK_CNT_256	EQU		0x29		;ディレイルーチン用
WORK_CNT_M		EQU		0x2a		;ディレイルーチン用
WORK_CNT_N		EQU		0x2b		;ディレイルーチン用
TMP_TMO			EQU		0x2c		;アラームタイムアウト用
TMP_CNT1		EQU		0x2d		;テンポラリ
TMP_CNT2		EQU		0x2e		;テンポラリ
TMP_CNT3		EQU		0x2f		;テンポラリ
TIM1			EQU		0x30		;1秒カウント用
TIM2			EQU		0x31		;3分カウント用
TIM_F			EQU		0x32		;1秒経過チェック用

;**********************************************************************
		ORG			0x000
		goto		main


; 割り込み処理ルーチン
		ORG			0x004
		movwf   	w_temp
		movf		STATUS,w
		movwf		status_temp
		movf    	status_temp,w
		movwf		STATUS
		swapf   	w_temp,f
		swapf   	w_temp,w
		retfie

;ここからメイン
main
		bcf			STATUS,RP0
 		bcf			STATUS,RP1

		;内部クロックキャリブレーション
		bsf			STATUS,RP0	;Bank=1 
;		movlw		0x70		;8MHz
		movlw		0x60		;4MHz
;		movlw		0x50		;2MHz
;;; TODO:試せ
		movwf		OSCCON
		bcf			STATUS,RP0	;Bank=0

		;ここからメイン処理
		;電源投入&リセット時の初期化処理

		clrf		INTCON		;割り込み禁止

		clrf		GPIO		;GPIO出力を0に
		movlw		0x07		;
		movwf		CMCON0		;コンパレータを使用禁止に設定

		bsf			STATUS,RP0	;Bank=1
		clrf		TRISIO		;GPIOを出力に設定
		bsf			TRISIO,5	;GP5だけ入力に設定
		clrf		IOC			;I/O状態変化チェック解除

;		movlw		b'10000111'	;プルアップ無し、エッジ割り込み無し、タイマー0は内部クロック
;		movwf		OPTION_REG	;プリスケーラー1/256に設定

		bcf			STATUS,RP0	; Bnak=0

		clrf		GPIO
main_loop
;; 		goto	blink_led
		
		bsf			LED_P		;音といっしょにLEDも

		movlw		d'5'		; 0.5秒間
		call		play_0do
		movlw		d'5'		; 0.5秒間
		call		play_0re
		movlw		d'5'		; 0.5秒間
		call		play_0mi
		movlw		d'5'		; 0.5秒間
		call		play_0fa
		movlw		d'5'		; 0.5秒間
		call		play_0so
		movlw		d'5'		; 0.5秒間
		call		play_0ra
		movlw		d'5'		; 0.5秒間
		call		play_0si
		movlw		d'5'		; 0.5秒間
		call		play_1do
		movlw		d'5'		; 0.5秒間
		call		play_1re
		movlw		d'5'		; 0.5秒間
		call		play_1mi
		movlw		d'5'		; 0.5秒間
		call		play_1fa
		movlw		d'5'		; 0.5秒間
		call		play_1so
		movlw		d'5'		; 0.5秒間
		call		play_1ra
		movlw		d'5'		; 0.5秒間
		call		play_1si
		movlw		d'5'		; 0.5秒間
		call		play_2do
		movlw		d'5'		; 0.5秒間
		call		play_2re
		movlw		d'5'		; 0.5秒間
		call		play_2mi
		movlw		d'5'		; 0.5秒間
		call		play_2fa
		movlw		d'5'		; 0.5秒間
		call		play_2so
		movlw		d'5'		; 0.5秒間
		call		play_2ra
		movlw		d'5'		; 0.5秒間
		call		play_2si
		movlw		d'5'		; 0.5秒間
		call		play_3do
	
		call		DLY_250
		call		DLY_250
		call		DLY_250
		call		DLY_250


	goto		main_loop
		clrf		GPIO
		goto		end_program

blink_led
		bsf			LED_P		;音といっしょにLEDも
		call		DLY_250
		bcf			LED_P		;音といっしょにLEDも
		call		DLY_250
		bsf			LED_P		;音といっしょにLEDも
		call		DLY_250
		bcf			LED_P		;音といっしょにLEDも
		call		DLY_250
		bsf			LED_P		;音といっしょにLEDも
		call		DLY_250
		bcf			LED_P		;音といっしょにLEDも
		call		DLY_250

		call		DLY_250
		call		DLY_250
		call		DLY_250
		call		DLY_250

		;true
		;movlw		0x01
		;movwf		WORK_CNT_N
		;rrf			WORK_CNT_N,f
		;btfsc		STATUS,Z
		;bsf			LED_P		;音といっしょにLEDも

		;; true
		;movlw		0x02
		;movwf		WORK_CNT_N
		;rrf			WORK_CNT_N,f
		;btfsc		STATUS,Z
		;bsf			LED_P		;音といっしょにLEDも
		
		; true
		;movlw		0x02
		;movwf		WORK_CNT_N
		;movlw		0x02
		;subwf		WORK_CNT_N,f
		;btfsc		STATUS,Z
		;bsf			LED_P
		
		; false
		;movlw		0x03
		;movwf		WORK_CNT_N
		;movlw		0x02
		;subwf		WORK_CNT_N,f
		;btfsc		STATUS,Z
		;bsf			LED_P
		
		; false
		;movlw		0x02
		;movwf		WORK_CNT_N
		;movlw		0x03
		;subwf		WORK_CNT_N,f
		;btfsc		STATUS,Z
		;bsf			LED_P
		
		;; false
		;movlw		0x02
		;movwf		WORK_CNT_N
		;movlw		0x03
		;subwf		WORK_CNT_N,f
		;btfsc		STATUS,C
		;bsf			LED_P
		
		; true
		;movlw		0x02
		;movwf		WORK_CNT_N
		;movlw		0x03
		;subwf		WORK_CNT_N,f
		;btfss		STATUS,C
		;bsf			LED_P
		
		; true
		;movlw		0x00
		;movwf		WORK_CNT_N
		;movlw		0x03
		;subwf		WORK_CNT_N,f
		;btfss		STATUS,C
		;bsf			LED_P

		call		DLY_250
		call		DLY_250
		call		DLY_250
		call		DLY_250
		call		DLY_250
		call		DLY_250
		call		DLY_250
		call		DLY_250
		bcf			LED_P		;音といっしょにLEDも
		call		DLY_250

		goto		blink_led
	
	
;	time_up
;			movlw		TIME_OUT	;ビープのタイムアウトを設定
;			movwf		TMP_TMO
;	beep							;ビープループ 音を断続で鳴りつづけさせる
;			bsf			LED_P		;音ともにLEDも点滅
;			movlw		d'2'
;			movwf		TMP_CNT1
;	beep1
;			movlw		d'250'
;			movwf		TMP_CNT2
;	beep2
;			call		sw_check	;スイッチが押されたか
;			andlw		0x01
;			btfss		STATUS,Z
;			goto		stanby_mode	;押されていればスタンバイモードへ
;			bsf			BEEP_P		;約0.5秒鳴って
;			call		DLY_05m
;			bcf			BEEP_P
;			call		DLY_05m
;			decfsz		TMP_CNT2,f
;			goto		beep2
;			decfsz		TMP_CNT1,f
;			goto		beep1
;			bcf			LED_P		;LEDオフ
;
;			call		DLY_250		;約0.5秒休む
;			call		DLY_250
;			decfsz		TMP_TMO,f	;タイムアウト時間経過してもスイッチ無ければスタンバイ
;			goto		beep



;;; 音を鳴らす
;;; @param w 長さ (100ms * N) のNを指定
;;; @param CNT_100ms 100ms 用カウンタ
;;; @param CNT_256 長さ 256サイクル用カウンタ
;;; @param CNT_M 長さ Nサイクル用カウンタ

play
		decfsz		CNT_N_100ms,f
		goto		play_100ms
		return
play_100ms
		movf		CNT_100ms,w
		movwf		WORK_CNT_100ms
play_100ms_loop
		bsf			BEEP_P
		call		delay_NMcycle
		bcf			BEEP_P
		call		delay_NMcycle
		decfsz		WORK_CNT_100ms,f
		goto		play_100ms_loop
		goto		play

;;; 約256*N+M サイクル待つ
;;; 
;;; WORK_CNT_256, WORK_CNT_M レジスタを使用
;;; @param CNT_256 256*N+M の N を指定
;;; @param CNT_M 256*N+M の M を指定
delay_NMcycle
		movf		CNT_256,w
		movwf		WORK_CNT_256
		incf		WORK_CNT_256
delay_NMcycle_loop
		decfsz		WORK_CNT_256,f
		goto		delay_NMcycle_256cycle
		movf		CNT_M,w
		movwf		CNT_N
		goto		delay_Ncycle
delay_NMcycle_256cycle
		call		delay_256cycle
		goto		delay_NMcycle_loop

;;; Nサイクル delay
;;;
;;; WORK_CNT_N レジスタを使用
;;; @param CNT_N サイクルを指定
delay_Ncycle
		;; 12cycle必要
		movf		CNT_N,w
		movwf		WORK_CNT_N
		bcf			STATUS,C		; ループに 4cycle 必要なので4で割る
		rrf			WORK_CNT_N,f
		bcf			STATUS,C
		rrf			WORK_CNT_N,f
		movlw		d'3'			; ここが 12cycle 必要なの3ループ分引いておく
		subwf		WORK_CNT_N,f
		btfsc		STATUS,Z
		return
		btfss		STATUS,C
		return
delay_Ncycle_loop
		; 1ループに 4cycle 必要
		nop
		decfsz		WORK_CNT_N,f
		goto		delay_Ncycle_loop
		return
delay_256cycle
		movlw		d'63'		;256/4-1 -1はここが4cycle必要なので1を引く
		movwf		WORK_CNT_N
		goto		delay_Ncycle_loop



;;; 周波数一覧表
;;; 		kHz		us			 	us/2				100msでNループ
;;; ド		261.626	3822.25008218	1911	7*256+126	26.164311879
;;; ド#		277.183	3607.72486047	1804	7*256+19
;;; レ		293.665	3405.24066538	1703	6*256+173	27.723870252
;;; レ#		311.127	3214.12156451	1607	6*256+77
;;; ミ		329.628	3033.7136599	1517	5*256+242	32.959789057
;;; ファ	349.228	2863.45882919	1432	5*256+157	34.928396787
;;; ファ#	369.994	2702.74653102	1352	5*256+77
;;; ソ		391.995	2561.0529471	1276	5*256+1		39.200313603
;;; ソ#		415.305	2407.86891562	1204	4*256+184
;;; ラ		440.000	2272.72727273	1137	4*256+117	43.994720634
;;; ラ#		466.164	2145.16779502	1073	4*256+53
;;; シ		493.883	2024.77104901	1013	3*256+248	49.382716049
;;; 
;;; 4mHz で 1cycle は 1us





play_0do
		movwf		CNT_N_100ms
		movlw		d'13'
		movwf		CNT_100ms
		movlw		d'14'
		movwf		CNT_256
		movlw		d'238'
		movwf		CNT_M
		goto		play
play_0re
		movwf		CNT_N_100ms
		movlw		d'15'
		movwf		CNT_100ms
		movlw		d'13'
		movwf		CNT_256
		movlw		d'77'
		movwf		CNT_M
		goto		play
play_0mi
		movwf		CNT_N_100ms
		movlw		d'16'
		movwf		CNT_100ms
		movlw		d'11'
		movwf		CNT_256
		movlw		d'218'
		movwf		CNT_M
		goto		play
play_0fa
		movwf		CNT_N_100ms
		movlw		d'17'
		movwf		CNT_100ms
		movlw		d'11'
		movwf		CNT_256
		movlw		d'47'
		movwf		CNT_M
		goto		play
play_0so
		movwf		CNT_N_100ms
		movlw		d'20'
		movwf		CNT_100ms
		movlw		d'9'
		movwf		CNT_256
		movlw		d'247'
		movwf		CNT_M
		goto		play
play_0ra
		movwf		CNT_N_100ms
		movlw		d'22'
		movwf		CNT_100ms
		movlw		d'8'
		movwf		CNT_256
		movlw		d'225'
		movwf		CNT_M
		goto		play
play_0si
		movwf		CNT_N_100ms
		movlw		d'25'
		movwf		CNT_100ms
		movlw		d'7'
		movwf		CNT_256
		movlw		d'233'
		movwf		CNT_M
		goto		play
play_1do
		movwf		CNT_N_100ms
		movlw		d'26'
		movwf		CNT_100ms
		movlw		d'7'
		movwf		CNT_256
		movlw		d'119'
		movwf		CNT_M
		call		play
        return
play_1re
		movwf		CNT_N_100ms
		movlw		d'29'
		movwf		CNT_100ms
		movlw		d'6'
		movwf		CNT_256
		movlw		d'117'
		movwf		CNT_M
		call		play
        return
play_1mi
		movwf		CNT_N_100ms
		movlw		d'33'
		movwf		CNT_100ms
		movlw		d'5'
		movwf		CNT_256
		movlw		d'237'
		movwf		CNT_M
		goto		play
play_1fa
		movwf		CNT_N_100ms
		movlw		d'35'
		movwf		CNT_100ms
		movlw		d'5'
		movwf		CNT_256
		movlw		d'152'
		movwf		CNT_M
		goto		play
play_1so
		movwf		CNT_N_100ms
		movlw		d'39'
		movwf		CNT_100ms
		movlw		d'4'
		movwf		CNT_256
		movlw		d'252'
		movwf		CNT_M
		goto		play
play_1ra
		movwf		CNT_N_100ms
		movlw		d'44'
		movwf		CNT_100ms
		movlw		d'4'
		movwf		CNT_256
		movlw		d'112'
		movwf		CNT_M
		goto		play
play_1si
		movwf		CNT_N_100ms
		movlw		d'49'
		movwf		CNT_100ms
		movlw		d'3'
		movwf		CNT_256
		movlw		d'244'
		movwf		CNT_M
		goto		play
play_2do
		movwf		CNT_N_100ms
		movlw		d'52'
		movwf		CNT_100ms
		movlw		d'3'
		movwf		CNT_256
		movlw		d'188'
		movwf		CNT_M
		goto		play
play_2re
		movwf		CNT_N_100ms
		movlw		d'59'
		movwf		CNT_100ms
		movlw		d'3'
		movwf		CNT_256
		movlw		d'83'
		movwf		CNT_M
		goto		play
play_2mi
		movwf		CNT_N_100ms
		movlw		d'66'
		movwf		CNT_100ms
		movlw		d'2'
		movwf		CNT_256
		movlw		d'246'
		movwf		CNT_M
		goto		play
play_2fa
		movwf		CNT_N_100ms
		movlw		d'70'
		movwf		CNT_100ms
		movlw		d'2'
		movwf		CNT_256
		movlw		d'204'
		movwf		CNT_M
		goto		play
play_2so
		movwf		CNT_N_100ms
		movlw		d'78'
		movwf		CNT_100ms
		movlw		d'2'
		movwf		CNT_256
		movlw		d'126'
		movwf		CNT_M
		goto		play
play_2ra
		movwf		CNT_N_100ms
		movlw		d'88'
		movwf		CNT_100ms
		movlw		d'2'
		movwf		CNT_256
		movlw		d'56'
		movwf		CNT_M
		goto		play
play_2si
		movwf		CNT_N_100ms
		movlw		d'99'
		movwf		CNT_100ms
		movlw		d'1'
		movwf		CNT_256
		movlw		d'250'
		movwf		CNT_M
		goto		play
play_3do
		movwf		CNT_N_100ms
		movlw		d'105'
		movwf		CNT_100ms
		movlw		d'1'
		movwf		CNT_256
		movlw		d'222'
		movwf		CNT_M
		goto		play

;スイッチ入力チェック
sw_check
		btfsc		PUSH_SW
		goto		sw_no		;押されていなければ0をもって即リターン
		call		DLY_100		;100mS待って
		btfsc		PUSH_SW		;まだ押されているなら1をもってリターン
		goto		sw_no
		goto		sw_yes
sw_no
		retlw		0x00
sw_yes
		retlw		0x01


;時間遅延ルーチン類
DLY_250	; 250mS
		movlw		d'250'
		movwf		CNT1
DLP1	; 1mS
		movlw		d'250'
		movwf		CNT_256
DLP2
		nop
		decfsz		CNT_256,f
		goto		DLP2
		decfsz		CNT1,f
		goto		DLP1
		return

DLY_100	; 100mS
		movlw		d'100'
		movwf		CNT1
DLP1_1	; 1mS
		movlw		d'250'
		movwf		CNT_256
DLP1_2
		nop
		nop
		decfsz		CNT_256,f
		goto		DLP1_2
		decfsz		CNT1,f
		goto		DLP1_1
		return

DLY_50	; 50mS
		movlw		d'50'
		movwf		CNT1
DLP5_1	; 1mS
		movlw		d'250'
		movwf		CNT_256
DLP5_2
		nop
		nop
		decfsz		CNT_256,f
		goto		DLP5_2
		decfsz		CNT1,f
		goto		DLP5_1
		return

DLY_05m	; ビープ音の周波数生成用
		movlw		d'60'	;これを減らすと高音、増やすと低音
		movwf		CNT_256	;ただし鳴動時間に影響する
DLY05_1
		nop
		nop
		nop
		decfsz		CNT_256,f
		goto		DLY05_1
		return	


;EEPROM初期化
 
		ORG	0x2100
		DE	0x00, 0x01, 0x02, 0x03

end_program
		END
