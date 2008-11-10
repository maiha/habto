class BoardsKeywords < Special::Migrations::Table
  habtm Board, Keyword, "boards_keywords"
end
