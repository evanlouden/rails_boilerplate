# Agent instructions

These instructions apply throughout this repository. Base Ruby design and style
decisions on [Shopify's Ruby Style Guide](https://github.com/Shopify/ruby-style-guide).
The Rails, testing, and workflow guidance below is this project's adaptation, not
a claim about Shopify's internal standards.

## Project context

- Rails 8.1 with PostgreSQL. Use the Ruby and Node versions in `.tool-versions`
  and dependency versions in the lockfiles.
- Authentication: Devise. Forms: SimpleForm and YAAF.
- UI: ViewComponent, ERB, Tailwind CSS, Turbo, and Stimulus. JavaScript is bundled
  with esbuild through Yarn; Lookbook provides component previews.
- Background infrastructure: Solid Queue, Solid Cache, and Solid Cable.
- Tests: RSpec, FactoryBot, Shoulda Matchers, and Capybara.

## Style precedence

`.rubocop.yml` currently inherits `rubocop-rails-omakase`, not `rubocop-shopify`.
Follow the checked-in RuboCop rules where they conflict with Shopify's guide;
use Shopify's guidance elsewhere. Do not disable cops to resolve that difference.
Switching to Shopify's published `rubocop-shopify` configuration should be a
separate, intentional tooling change that updates dependencies and configuration
together. Avoid unrelated formatting changes.

## Ruby conventions from Shopify

- Use two-space indentation, a final newline, and no trailing whitespace. Aim for
  lines of at most 120 characters.
- Use `snake_case` for methods and files, `CamelCase` for classes and modules, and
  `SCREAMING_SNAKE_CASE` for constants. Use `?` for boolean predicates.
- Keep methods short and at one level of abstraction. Prefer guard clauses to
  deeply nested conditionals.
- Prefer keyword arguments over options hashes and long positional argument lists.
- Avoid mutating arguments, monkeypatching, and unnecessary metaprogramming.
- Use parentheses for ordinary calls with arguments; retain conventional Rails
  DSL syntax. Prefer implicit returns and omit unnecessary `self`.
- Use braces for single-line blocks and `do`/`end` for multiline blocks.
- Prefer `public_send` to `send` when dynamic dispatch is necessary.
- Explain non-obvious decisions in comments rather than restating the code.

## Rails implementation

- Follow Rails naming and autoloading conventions. Match namespaces to paths and
  existing inflections in `config/initializers/inflections.rb`.
- Keep controllers focused on HTTP concerns: authentication, authorization,
  permitted parameters, delegation, and responses.
- Keep persistence rules and associations in models. Use focused objects in
  `app/services` for workflows spanning models or external systems; avoid adding
  a service layer around trivial Active Record operations.
- Use YAAF when a form coordinates multiple models or needs its own validation
  lifecycle. Keep presentation logic in ViewComponents or helpers.
- Extend the existing Hotwire and Tailwind approach for interactive UI. Reuse
  components and add Lookbook previews when useful for reviewing UI states.
- Scope record access to the authorized user or context. Authentication alone
  does not authorize access to a record.
- Use parameterized queries and explicit permitted attributes. Preserve Rails'
  escaping and CSRF protections; never log credentials or tokens.
- Watch for N+1 queries and unbounded result sets. Preload associations when
  needed and use batches for large data operations.
- Back integrity requirements with appropriate database constraints and indexes.
  Use transactions for related writes that must succeed together.
- Make migrations reversible where practical. Consider locks and existing data;
  separate large backfills from schema changes. Generate schema changes through
  migrations rather than editing `db/schema.rb` manually.
- Make jobs safe to retry and enqueue work only when its required data is
  committed. Keep external network calls out of database transactions.
- Use zone-aware application time, such as `Time.current` and `Date.current`.

## Testing and verification

- Add focused RSpec coverage for changed behavior and bug regressions. Test
  observable outcomes, including relevant failure and authorization cases.
- Follow `spec/rails_helper.rb` for Rails specs and `spec/spec_helper.rb` for
  isolated Ruby specs. Use FactoryBot when test data is needed; avoid unnecessary
  persistence and implementation-coupled mocks.
- Run focused specs first: `bundle exec rspec spec/path/to/changed_spec.rb`.
  Run `bundle exec rspec` for changes with broad effects.
- Run `bin/rubocop` for Ruby changes and `bin/brakeman --no-pager` for security
  checks. These are the checks currently configured in GitHub Actions; CI does
  not currently run RSpec.
- For frontend changes, run `yarn build` and, when CSS is affected,
  `bin/rails tailwindcss:build`. Check affected UI behavior where possible.
- `bin/dev` starts Rails and the asset watchers. `bin/setup --skip-server`
  installs Ruby dependencies and prepares the local database; it also clears
  logs and temporary files. Install JavaScript dependencies with `yarn install`.
- Do not rely on `bin/ci` without checking it: `config/ci.rb` currently references
  a missing `bin/importmap`, while this project uses esbuild.
- For documentation-only changes, check the diff and referenced paths; application
  tests are unnecessary. Report commands run, failures, and checks blocked by
  missing dependencies or environment configuration.

## Change discipline

- Read nearby code before editing and keep changes focused on the requested task.
- Preserve unrelated work. Avoid introducing dependencies or architectural
  frameworks without a concrete need.
- Keep secrets and local credentials out of commits. Update documentation when
  behavior, setup, or configuration changes.
- Summarize what changed and how it was verified, including remaining limitations.
