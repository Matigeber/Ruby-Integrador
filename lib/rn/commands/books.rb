module RN
  module Commands
    module Books
      require 'rn/models/Book'
      class Create < Dry::CLI::Command
        desc 'Create a book'

        argument :name, required: true, desc: 'Name of the book'

        example [
          '"My book" # Creates a new book named "My book"',
          'Memoires  # Creates a new book named "Memoires"'
        ]

        def call(name:, **)
          Helper.check_folder_name name
          abort("This book already exists") unless not Dir.exist? name
          Book.new(name).create
          puts "Book created successfully"
        end
      end

      class Delete < Dry::CLI::Command
        desc 'Delete a book'

        argument :name, required: false, desc: 'Name of the book'
        option :global, type: :boolean, default: false, desc: 'Operate on the global book'

        example [
          '--global  # Deletes all notes from the global book',
          '"My book" # Deletes a book named "My book" and all of its notes',
          'Memoires  # Deletes a book named "Memoires" and all of its notes'
        ]

        def call(name: nil, **options)
          global = options[:global]
          if name.nil? and not global
            abort "you must enter a book name or --global"
          elsif global
            Book.new(Helper.global_book).delete_childs
          else
            Helper.book_exists? name
            book = Book.new(name)
            book.delete_childs
            book.delete
            puts "Book deleted successfully"
          end
        end
      end

      class List < Dry::CLI::Command
        desc 'List books'

        example [
          '          # Lists every available book'
        ]

        def call(*)
          Book.list
        end
      end

      class Rename < Dry::CLI::Command
        desc 'Rename a book'

        argument :old_name, required: true, desc: 'Current name of the book'
        argument :new_name, required: true, desc: 'New name of the book'

        example [
          '"My book" "Our book"         # Renames the book "My book" to "Our book"',
          'Memoires Memories            # Renames the book "Memoires" to "Memories"',
          '"TODO - Name this book" Wiki # Renames the book "TODO - Name this book" to "Wiki"'
        ]

        def call(old_name:, new_name:, **)
          abort "global book cannot be renamed" unless not old_name == Helper.global_book
          abort "this book cannot be renamed because a book with this name already exists" unless not Helper.book_exists? new_name
          Helper.check_folder_name new_name
          Book.new(old_name).rename Helper.format_name new_name
          puts "book renamed successfully"
        end
      end
    end
  end
end

