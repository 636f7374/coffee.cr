module Coffee::Render
  module Progress
    def self.mark(writer : Writer)
      value = String.build do |io|
        io << "Mark: " << "🎯  (Matchd) | 🚫  (Mismatch) | ⛔️  (Failure) | ⚠️  (Invalid)"
      end

      writer.write value
    end

    def self.push(writer : Writer, task : Task)
      value = String.build do |io|
        io << (task.finished? ? "🍺  " : "🚧  ")
        io << task.ipRange.to_s << "/" << task.ipRange.prefix << " "
        io << "(" << task.progress.position << "/" << task.progress.total << ")" << " | "

        io << "🎯 : " << task.progress.matched << ", " << "🚫 : " << task.progress.mismatch << ", "
        io << "⛔️ : " << task.progress.failure << ", " << "⚠️ : " << task.progress.invalid

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
