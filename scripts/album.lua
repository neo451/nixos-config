local input = [==[
`<Club Icarus>` - [[ARTMS]]
`WHAT HAVE WE DONE` - [[pH-1]]
`No.I` - [[Number_i]]
`ROSE` - [[HANA]]
`SEQUENCE 01` - [[f5ve]]
`WHO I AM` - [[MEI]]
`Metal Forth` - [[Baby Metal]]
`Eve: Romance` - [[BIBI]]
`LIL FANTASY vol.1` - `彩瑛`
`DETOX` - `ONE OK ROCK`
`Prema` - `藤井风`
`My First Flip` - `Kickflip`
`Kick Out, Flip Now!` - `Kickflip`
`Flip it, Kick it!` - `Kickflip`
`ENEMY` - `TWICE`
`THIS IS FOR` - `TWICE`
`AWAKE` - `NiziU`
`The Life of a Showgirl` - `Taylor Swift`
`Eusexua Afterglow` - `FKA twigs`
`Eusexua` - `FKA twigs`
`I Love My Computer` - `Ninajirachi`
`Son of Spergy` - `Daniel Caesar`
`Do What I Want` - `MONSTA X`
`LXVE to DEATH` - `Xdinary Heroes`
`Magic, Alive!` - `McKinley Dixon`
`The Art of Loving` - `Olivia Dean`
`DO IT` - `Stray Kids`
`DUH!` - `P1Harmony`
`New Emotion` - `NiziU`
`钱专` - `河南说唱之神`
`KARMA` - `Stray Kids`
`Hollow` - `Stray Kids`
`Girls Will Be Girls` - `ITZY`
`悲伤角斗士` - `SHarK`
`配合尺寸` - `李欣颖`
`MAGICMAN 2` - `王嘉尔`
`224` - `KISS OF LIFE`
`<ASSEMBLE25>` - `tripleS`
`<Club Icarus>` - `ARTMS`
`归魂桥` - `孔岱山`
`龙年` - `华云龙KLE`
`Gen` - `星野源`
`Fe3O4: FORWARD` - `NMIXX`
`Essence of Reverie` - `BAEKHYUN`
`O-RLY?` - `NEXZ`
`F*CK U SKRILLEX YOU THINK UR ANDY WARHOL BUT UR NOT!! <3` - `Skrillex`
`AIR` - `YEJI`
`G-BLOCK Mixtape` - `G-BLOCK`
`八方来财之江船入海` - `揽佬SKAI ISYOURGOD`
`IMGOOD别担心我` - `Rapeter`
`羞于启齿` - `陈一豪`
`#DBAA` - `黄之仪Kyra Zilver`
`HUNTER` - `Key`
`Let God Sort Em Out` - `Clipse`
`Willoughby Tucker, I'll Always Love You` - `Ethel Cain`
`Heart Maid` - `SUNMI`
`Soft Error: X` - `Yves`
`Skepta .. Fred` - `Skepta`/`Fred again..`
`black british music (2025)` - `Jim Legxacy`
`TUNNEL VISION` - `ITZY`
`Essex Honey` - `Blood Orange`
`LUX` - `ROSALÍA`
`the Death of Music` - `galen tipton`
`The DECADE` - `DAY6`
`Growing Pain Pt.1 : Free` - `YOUNG POSSE`
`A Montage of ( )` - `VIVIZ`
`Lotus` - `Little Simz`
`Fancy That` - `PinkPantheress`
`兰州说唱民星` - `萨萨`
`ERA*` - `2z2`
`choke enough` - `oklou`
`ALLDAY PROJECT` - `ALLDAY PROJECT`
`Addison` - `Addison Rae`
`Sir.Robert` - `BOBBY`
`Lovestruck` - `H1-KEY`
`msnz<Beyond Beauty>` - `tripleS`
]==]

local albums = {}

local Note = require("obsidian.note")
local util = require("obsidian.util")

for line in input:gmatch("[^\n]+") do
   -- match `album` - [[artist]]  OR  `album` - `artist`
   local album, artist = line:match("^`(.*)`%s*%-%s*%[%[(.*)%]%]$")
   if not album then
      album, artist = line:match("^`(.*)`%s*%-%s*`(.*)`$")
   end

   if album and artist then
      albums[album] = artist
   else
      print("Failed to parse line:", line)
   end
end

-- Example: print result
for k, v in pairs(albums) do
   local safe_id = k
   if util.contains_invalid_characters(k) then
      safe_id = string.gsub(k, "[#^[]|]", "")
   end
   local note = Note.create({ title = safe_id })
   local image = "image: " .. (("http://localhost:9000/%s/%s"):format(util.urlencode(v), util.urlencode(k)))
   vim.fn.writefile({
      "---",
      ("name: %s"):format(k),
      ("artist: %s"):format(v),
      "year: 2025",
      image,
      "---",
   }, tostring(note.path))
end
