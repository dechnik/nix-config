{
  sources,
  fetchFromGitHub,
  buildVimPlugin,
}: {
  nvim-session-manager = buildVimPlugin sources.nvim-session-manager;
}
