module CLISupport
  # TODO generate these lists

  def all_actions
    most_actions + [:execute, :repl]
  end

  def most_actions
    [
      :help,
      :do,
      :version,
      :parse_tree,
      :syntax_tree
    ]
  end

  def global_options
    [
      :verbose
    ]
  end
end

World CLISupport
