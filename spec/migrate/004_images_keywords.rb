class ImagesKeywords < Special::Migrations::Table
  habtm Image, Keyword, "images_keywords"
end
