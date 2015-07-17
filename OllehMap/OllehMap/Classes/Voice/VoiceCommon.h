//
//  VoiceCommon.h
//  OllehMap
//
//  Created by 이 제민 on 12. 5. 29..
//  Copyright (c) 2012년 jmlee@miksystem.com. All rights reserved.
//

#ifndef OllehMap_VoiceCommon_h
#define OllehMap_VoiceCommon_h

enum RESULT_KEYS {
    KEY_NBEST,
    KEY_COUNT,
    KEY_INDEX,
    KEY_WORD,
    KEY_ALTER,
    KEY_CLASS,
    KEY_CONF,
    KEY_MAX
};

enum AUTO_KEYS{
    AUTO_KEY_AUTOITEM,
    AUTO_KEY_SEARCHWORD,
    AUTO_KEY_MAX
};

#define BYTE                unsigned char
#define EUC_KR	 0x80000000 + kCFStringEncodingDOSKorean
#define NEED_TO_PARSE_KEYS  5


#endif
