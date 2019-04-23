{application,benchee,
             [{applications,[kernel,stdlib,elixir,logger,deep_merge]},
              {description,"Versatile (micro) benchmarking that is extensible. Get statistics such as:\naverage, iterations per second, standard deviation and the median.\n"},
              {modules,['Elixir.Benchee','Elixir.Benchee.Benchmark',
                        'Elixir.Benchee.Benchmark.Measure',
                        'Elixir.Benchee.Benchmark.Measure.Memory',
                        'Elixir.Benchee.Benchmark.Measure.Time',
                        'Elixir.Benchee.Benchmark.Runner',
                        'Elixir.Benchee.Benchmark.Scenario',
                        'Elixir.Benchee.Benchmark.ScenarioContext',
                        'Elixir.Benchee.Configuration',
                        'Elixir.Benchee.Conversion',
                        'Elixir.Benchee.Conversion.Count',
                        'Elixir.Benchee.Conversion.DeviationPercent',
                        'Elixir.Benchee.Conversion.Duration',
                        'Elixir.Benchee.Conversion.Format',
                        'Elixir.Benchee.Conversion.Memory',
                        'Elixir.Benchee.Conversion.Scale',
                        'Elixir.Benchee.Conversion.Unit',
                        'Elixir.Benchee.Formatter',
                        'Elixir.Benchee.Formatters.Console',
                        'Elixir.Benchee.Formatters.Console.Helpers',
                        'Elixir.Benchee.Formatters.Console.Memory',
                        'Elixir.Benchee.Formatters.Console.RunTime',
                        'Elixir.Benchee.Formatters.TaggedSave',
                        'Elixir.Benchee.Output.BenchmarkPrinter',
                        'Elixir.Benchee.ScenarioLoader',
                        'Elixir.Benchee.Statistics',
                        'Elixir.Benchee.Statistics.Mode',
                        'Elixir.Benchee.Statistics.Percentile',
                        'Elixir.Benchee.Suite','Elixir.Benchee.System',
                        'Elixir.Benchee.Utility.DeepConvert',
                        'Elixir.Benchee.Utility.FileCreation',
                        'Elixir.Benchee.Utility.Parallel',
                        'Elixir.Benchee.Utility.RepeatN',
                        'Elixir.DeepMerge.Resolver.Benchee.Configuration',
                        'Elixir.DeepMerge.Resolver.Benchee.Suite',benchee]},
              {registered,[]},
              {vsn,"0.13.2"}]}.