return {
  'harrisoncramer/jump-tag',
  enabled = false,
  keys = {
    {
      ']s',
      function()
        require('jump-tag').jumpNextSibling()
      end,
      desc = 'Jump to next sibling tag',
    },
    {
      '[s',
      function()
        require('jump-tag').jumpPrevSibling()
      end,
      desc = 'Jump to prev sibling tag',
    },
    {
      '[o',
      function()
        require('jump-tag').jumpParent()
      end,
      desc = 'Jump to outer tag',
    },
    {
      ']i',
      function()
        require('jump-tag').jumpChild()
      end,
      desc = 'Jump to inner tag',
    },
  },
}
