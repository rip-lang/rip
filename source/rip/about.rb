module Rip
  module About
    def self.logo
      <<-'RIP'
         _            _          _
        /\ \         /\ \       /\ \
       /  \ \        \ \ \     /  \ \
      / /\ \ \       /\ \_\   / /\ \ \
     / / /\ \_\     / /\/_/  / / /\ \_\
    / / /_/ / /    / / /    / / /_/ / /
   / / /__\/ /    / / /    / / /__\/ /
  / / /_____/    / / /    / / /_____/
 / / /\ \ \  ___/ / /__  / / /
/ / /  \ \ \/\__\/_/___\/ / /
\/_/    \_\/\/_________/\/_/
      RIP
    end

    def self.summary(verbose = false)
        <<-SUMMARY
#{version(verbose)}
#{copyright(verbose)}
        SUMMARY
    end

    def self.copyright(verbose = false)
      'copyright © Thomas Ingram'
    end

    def self.version(verbose = false)
      reply = 'v0.2.0'
      verbose ? "#{logo.rstrip} #{reply}" : reply
    end
  end
end
