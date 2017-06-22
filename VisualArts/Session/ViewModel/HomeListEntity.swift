//
//  HomeListEntity.swift
//  VisualArts
//
//  Created by 木瓜 on 2017/6/22.
//  Copyright © 2017年 WHY. All rights reserved.
//

import UIKit
import MappingAce

struct DocEntity: Mapping {
    var web_url: String?
    var snippet: String?
    var lead_paragraph: String?
    var abstract: String?
    var print_page: String?
    var source: String?
    var headline: Headline?
    var pub_date: String?
    var document_type: String?
    var news_desK: String?
    var section_name: String?
    var subsection_name: String?
    var type_of_material: String?
    var word_count: String?
    var slideshow_credits: String?
    var multimedia: [Multimedia]?
}

struct Headline: Mapping {
    var main: String?
    var print_headline: String?
}

struct Multimedia: Mapping {
    var width: Int
    var height: Int
    var url: String
    var rank: Int
    var subtype: String // thumbnail xlarge wide
    var type: String
}
