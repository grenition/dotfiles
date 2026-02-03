local map = vim.keymap.set

-- Window navigation
map("n", "<C-h>", "<C-w>h", { silent = true, desc = "Navigate Left" })
map("n", "<C-l>", "<C-w>l", { silent = true, desc = "Navigate Right" })
map("n", "<C-j>", "<C-w>j", { silent = true, desc = "Navigate Down" })
map("n", "<C-k>", "<C-w>k", { silent = true, desc = "Navigate Up" })
--
-- Split windows
map("n", "<leader>v", "<C-w>v", { silent = true, desc = "Split Vertically" })
map("n", "<leader>h", "<C-w>s", { silent = true, desc = "Split Horizontally" })
map("n", "<D-o>", "<C-w>r", { silent = true, desc = "Move Editor to Opposite Tab Group" })

-- Close and save
map("n", "<leader>x", "<cmd>close<cr>", { silent = true, desc = "Close Content" })
map("n", "<leader>w", "<cmd>w<cr>", { silent = true, desc = "Save Document" })

-- Buffer management
map("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", { silent = true, desc = "Pin Active Editor Tab" })
map("n", "<leader>bq", "<cmd>BufferLineCloseOther<cr>", { silent = true, desc = "Close All Editors But Active" })

map({ "n", "x", "o" }, "й", "q")
map({ "n", "x", "o" }, "ц", "w")
map({ "n", "x", "o" }, "у", "e")
map({ "n", "x", "o" }, "к", "r")
map({ "n", "x", "o" }, "е", "t")
map({ "n", "x", "o" }, "н", "y")
map({ "n", "x", "o" }, "г", "u")
map({ "n", "x", "o" }, "ш", "i")
map({ "n", "x", "o" }, "щ", "o")
map({ "n", "x", "o" }, "з", "p")
map({ "n", "x", "o" }, "х", "[")
map({ "n", "x", "o" }, "ъ", "]")

map({ "n", "x", "o" }, "Й", "Q")
map({ "n", "x", "o" }, "Ц", "W")
map({ "n", "x", "o" }, "У", "E")
map({ "n", "x", "o" }, "К", "R")
map({ "n", "x", "o" }, "Е", "T")
map({ "n", "x", "o" }, "Н", "Y")
map({ "n", "x", "o" }, "Г", "U")
map({ "n", "x", "o" }, "Ш", "I")
map({ "n", "x", "o" }, "Щ", "O")
map({ "n", "x", "o" }, "З", "P")
map({ "n", "x", "o" }, "Х", "{")
map({ "n", "x", "o" }, "Ъ", "}")

map({ "n", "x", "o" }, "ф", "a")
map({ "n", "x", "o" }, "ы", "s")
map({ "n", "x", "o" }, "в", "d")
map({ "n", "x", "o" }, "а", "f")
map({ "n", "x", "o" }, "п", "g")
map({ "n", "x", "o" }, "р", "h")
map({ "n", "x", "o" }, "о", "j")
map({ "n", "x", "o" }, "л", "k")
map({ "n", "x", "o" }, "д", "l")
map({ "n", "x", "o" }, "ж", ";")
map({ "n", "x", "o" }, "э", "'")

map({ "n", "x", "o" }, "Ф", "A")
map({ "n", "x", "o" }, "Ы", "S")
map({ "n", "x", "o" }, "В", "D")
map({ "n", "x", "o" }, "А", "F")
map({ "n", "x", "o" }, "П", "G")
map({ "n", "x", "o" }, "Р", "H")
map({ "n", "x", "o" }, "О", "J")
map({ "n", "x", "o" }, "Л", "K")
map({ "n", "x", "o" }, "Д", "L")
map({ "n", "x", "o" }, "Ж", ":")
map({ "n", "x", "o" }, "Э", '"')

map({ "n", "x", "o" }, "я", "z")
map({ "n", "x", "o" }, "ч", "x")
map({ "n", "x", "o" }, "с", "c")
map({ "n", "x", "o" }, "м", "v")
map({ "n", "x", "o" }, "и", "b")
map({ "n", "x", "o" }, "т", "n")
map({ "n", "x", "o" }, "ь", "m")
map({ "n", "x", "o" }, "б", ",")
map({ "n", "x", "o" }, "ю", ".")

map({ "n", "x", "o" }, "Я", "Z")
map({ "n", "x", "o" }, "Ч", "X")
map({ "n", "x", "o" }, "С", "C")
map({ "n", "x", "o" }, "М", "V")
map({ "n", "x", "o" }, "И", "B")
map({ "n", "x", "o" }, "Т", "N")
map({ "n", "x", "o" }, "Ь", "M")
map({ "n", "x", "o" }, "Б", "<")
map({ "n", "x", "o" }, "Ю", ">")

-- vimrc

map("n", "U", "<C-r>", { noremap = true, silent = true })

map("n", "<M-h>", "20h", { noremap = true, silent = true })
map("n", "<M-j>", "10j", { noremap = true, silent = true })
map("n", "<M-k>", "10k", { noremap = true, silent = true })
map("n", "<M-l>", "20l", { noremap = true, silent = true })

map("n", "H", "20h", { noremap = true, silent = true })
map("n", "J", "10j", { noremap = true, silent = true })
map("n", "K", "10k", { noremap = true, silent = true })
map("n", "L", "20l", { noremap = true, silent = true })

map({ "n", "v" }, "d", '"_d', { noremap = true, silent = true })
map({ "n", "v" }, "D", '"_D', { noremap = true, silent = true })
map("n", "x", '"_x', { noremap = true, silent = true })
map("n", "X", '"_X', { noremap = true, silent = true })
map({ "n", "v" }, "c", '"_c', { noremap = true, silent = true })
map({ "n", "v" }, "C", '"_C', { noremap = true, silent = true })

map({ "n", "v" }, "<Tab>", "<cmd>tabnext<cr>", { noremap = true, silent = true })
map({ "n", "v" }, "<S-Tab>", "<cmd>tabprevious<cr>", { noremap = true, silent = true })
