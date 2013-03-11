class Fuse::Document::Asset
  class Font < self
    CSS_FORMATS = [
        { extension: :woff, format: 'woff' },
        { extension: :ttf,  format: 'truetype' },
        { extension: :otf,  format: 'opentype' }
    ]
    MIME_TYPES = {
        otf: 'application/x-font-opentype',
        ttf: 'application/x-font-truetype',
        woff: 'application/x-font-woff'
    }
    VARIANT_PATTERN = %r`([^/]+?)(?:[-_ ](normal|bold|bolder|lighter|[1-9]00))?(?:[-_ ](normal|italic|oblique))?\.[a-z]+$`
    def family; @family ||= variant[:family] end
    def weight; @weight ||= variant[:weight] end
    def style;  @style  ||= variant[:style]  end
    def variant
      @variant ||= begin
        match = VARIANT_PATTERN.match(path)
        {
            family: match[1],
            weight: match[2] || 'normal',
            style:  match[3] || 'normal'
        }
      end
    end
    def face; @face ||= [family, weight, style].join('-') end
    def type
      MIME_TYPES[extension.to_sym] || super
    end
  end
end
