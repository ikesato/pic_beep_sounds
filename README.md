pic_beep_sounds
==================
- 圧電スピーカを使ってドレミを実現
- チャルメラを鳴らしてみた


他
--
- PIC12F683 はやっぱり工場出荷のロード 0x3ff があると動かない


pickit2 との接続方法
--------------------
![回路図] (http://www006.upp.so-net.ne.jp/picbegin/proj1/pic_zu802.gif)

pickit2 での書き込み方法
------------------------
$ pk2cmd -PPIC12F683 -M -F dist/default/production/pic_beep_sounds.production.hex


pickit2 で電源供給方法
----------------------
$ pk2cmd -PPIC12F683 -T         # 5V 供給  
$ pk2cmd -PPIC12F683 -T -A 3.3  # 3.3V 供給  
$ pk2cmd -PPIC12F683 -W         # pickit2 からの電源供給停止  
