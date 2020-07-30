module Coffee::Render
  module Progress
    def self.mark(writer : Writer)
      value = String.build do |io|
        io << "Info: " << "🎯  (Matched) | 🚫  (Mismatch) | ⛔️  (Failure) | ⚠️  (Invalid)"
      end

      writer.write value
    end

    def self.push(writer : Writer, task : Task)
      return unless progress = task.progress

      value = String.build do |io|
        io << (task.finished? ? "🍺  " : "🚧  ")
        io << task.ipRange.to_s << "/" << task.ipRange.prefix << " "
        io << "(" << progress.position << "/" << progress.total << ")" << " | "

        io << "🎯 : " << progress.matched << ", " << "🚫 : " << progress.mismatch << ", "
        io << "⛔️ : " << progress.failure << ", " << "⚠️ : " << progress.invalid

        if task_timing = task.timing
          io << " | " << Elapsed.to_text task_timing
        else
          io << "     "
        end
      end

      writer.write value
    end
  end
end
