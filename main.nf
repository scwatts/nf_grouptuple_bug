#!/usr/bin/env nextflow
import java.util.concurrent.TimeUnit


nextflow.enable.dsl = 2


process ONE {
  input:
  val(meta)

  output:
  tuple val(meta), path("*.txt")

  script:
  """
  touch "${meta.name}_ONE_a.txt"
  """
}

process TWO {
  input:
  val(meta)

  output:
  tuple val(meta), path("*txt")

  script:
  """
  touch "${meta.name}_TWO.txt"
  """
}

process THREE {
  input:
  tuple val(meta), path(file_one_a), path(file_two)

  output:
  tuple val(meta), path("*txt")

  script:
  """
  touch "${meta.name}_THREE.txt"
  """
}

ch_inputs = Channel.from(
  ['name': 'sample_one'],
  ['name': 'sample_two'],
)

workflow {
  // Run process ONE and TWO
  ONE(ch_inputs)
  TWO(ch_inputs)

  // Prepare input channgel for process THREE, then run
  ch_three_input = Channel.empty()
    .concat(
      ONE.out,
      TWO.out,
    )
    .map { [it[0], it[1..-1]] }
    .groupTuple()
    .map { it.flatten() }
  THREE(ch_three_input)


  // Disply contents of channels
  Channel.from('channel ONE').combine(ONE.out.collect()).view()
  Channel.from('channel TWO').combine(TWO.out.collect()).view()
  Channel.from('channel THREE').combine(THREE.out.collect()).view()
  Channel.from('channel ch_tree_input').combine(ch_three_input.collect()).view()

  // Group outputs for a supposed final process, triggers the described bug
  ch_final_works = Channel

    // NOTE(SW): here I force eval after all processes and above .view calls complete; sleep for
    // five seconds then clear channel contents
    .from('foobar')
    .map { TimeUnit.SECONDS.sleep(5); it }
    .filter { false }

    // Actual problematic code - error triggered on .groupTuple call
    .concat(
      THREE.out,
      // Using ONE.out and TWO.out inplace of ch_three_input (i.e. source of ch_three_input) does
      // not trigger the error
      ch_three_input,
    )
    .groupTuple()
}
