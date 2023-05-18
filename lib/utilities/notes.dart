/*
${Values.baseUrl}/anime?include=animethemes.animethemeentries.videos,animethemes.song,images&fields[anime]=name,slug,year,season&fields[animetheme]=type,sequence,slug,group&fields[animethemeentry]=version,episodes,spoiler,nsfw&fields[video]=tags,resolution,nc,subbed,lyrics,uncen,source,overlap&fields[image]=facet,link&fields[song]=title&page[size]=15&page[number]=1&q=shingeki

/api/anime
include
	animethemes.animethemeentries.videos,animethemes.song,images
fields[anime]
	name,slug,year,season
fields[animetheme]
	type,sequence,slug,group
fields[animethemeentry]
	version,episodes,spoiler,nsfw
fields[video]
	tags,resolution,nc,subbed,lyrics,uncen,source,overlap
fields[image]
	facet,link
fields[song]
	title
page[size]
	15
page[number]
	1
q
	shingeki


${Values.baseUrl}/animetheme?include=animethemeentries.videos,anime.images,song.artists&fields[anime]=name,slug,year,season&fields[animetheme]=id,type,sequence,slug,group&fields[animethemeentry]=version&fields[video]=tags&fields[image]=facet,link&fields[song]=title&fields[artist]=name,slug,as&filter[has]=song&page[size]=15&page[number]=1&q=shingeki

/api/animetheme

include
	animethemeentries.videos,anime.images,song.artists
fields[anime]
	name,slug,year,season
fields[animetheme]
	id,type,sequence,slug,group
fields[animethemeentry]
	version
fields[video]
	tags
fields[image]
	facet,link
fields[song]
	title
fields[artist]
	name,slug,as
filter[has]
	song
page[size]
	15
page[number]
	1
q
	shingeki


//https://themes.moe/api/themes/38691/OP2/audio
//https://animethemes.moe/video/DrStone-OP2-NCBD1080.webm
//${Values.baseUrl}/search?q=Shingeki&fields[search]=animethemes&include[animetheme]=animethemeentries.videos,anime.images,song.artists
//${Values.baseUrl}/animeyear/2022&fields[search]=animethemes&include[animetheme]=animethemeentries.videos,anime.images,song.artists

*/