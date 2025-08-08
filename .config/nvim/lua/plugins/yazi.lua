return {
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>yy",
        "<Cmd>Yazi<CR>",
        desc = "Open yazi at the current file",
      },
      {
        "<leader>ye",
        "<Cmd>Yazi cwd<CR>",
        desc = "Open the file manager in nvim's working directory",
      },
      {
        "<leader>yr",
        "<Cmd>Yazi toggle<CR>",
        desc = "Resume the last yazi session",
      },
    },
    opts = {
      -- if you want to open yazi instead of netrw, see below for more info
      open_for_directories = true,
      floating_window_scaling_factor = 1,
      yazi_floating_window_winblend = 0,
      keymaps = {
        show_help = "<f1>",
        open_file_in_vertical_split = "<C-v>",
        open_file_in_horizontal_split = "<C-x>",
        open_file_in_tab = "<C-t>",
        grep_in_directory = "<C-s>",
        replace_in_directory = "<C-g>",
        cycle_open_buffers = "<tab>",
        copy_relative_path_to_selected_files = "<C-y>",
        send_to_quickfix_list = "<C-q>",
        change_working_directory = "<C-\\>",
      },
    },
    highlight_hovered_buffers_in_same_directory = true,
  },
}
