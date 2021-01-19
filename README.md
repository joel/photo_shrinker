# PhotoShrinker

Reducing your Photo sizes without losing quality.

When you have a lot of old Photos, like me, they have almost 20 years old, you might when to reduce the huge amount of space taken by those. After all, the only thing we want is to have a look at it a remember a good time.

## Installation

### Docker

```
git clone https://github.com/joel/photo_shrinker
```

```
cd photo_shrinker
```

```
docker build --tag photo:shrinker .
```

### Macos

```
git clone https://github.com/joel/photo_shrinker
```

```
cd photo_shrinker
```

```
bundle install
```

## Usage

### Docker

```
docker run --rm --name shrinker \
  --mount type=bind,source=(pwd),target=/workdir \
  --workdir /workdir \
  --mount "type=bind,source=/Volumes/My Backup Hard Disk,target=/workdir/unshrinked" \
  --mount "type=bind,source=/Volumes/Other Hard Disk/Pictures,target=/workdir/shrinked" \
-it photo:shrinker sh -c "sh /workdir/bin/shrink --no-verbose --source_directory '/workdir/unshrinked' --target_directory '/workdir/shrinked' --parallel 8"
```

### Macos

```
cd photo_shrinker
```

```
bin/shrink --help
```

```
bin/shrink.rb --help

Usage: bin/shrink -s /Volume/Ext/Source -t /Volume/Ext/Destination --no-verbose

Specific options:
    -s SOURCE_DIRECTORY,             [OPTIONAL] Where the pictures are
        --source_directory
    -t TARGET_DIRECTORY,             [OPTIONAL] Where the pictures will go
        --target_directory
    -n, --parallel PARALLEL          [OPTIONAL] How many threads
    -v, --[no-]verbose               Run verbosely

Common options:
    -h, --help                       Show this message
        --version                    Show version
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/photo_shrinker. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/photo_shrinker/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Photoshrinker project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/photo_shrinker/blob/master/CODE_OF_CONDUCT.md).
