include { SAMTOFASTQ       } from './modules/samtofastq'
include { SAMTOOLS_INDEX   } from './modules/samtools_index'



Channel.fromPath(params.input)
    .splitCsv(header:true, sep:',')
    .map { row -> [ ["id" : row.id], file(row.bam, checkIfExists: true) ] }
    .set { ch_bam }



workflow index {
    SAMTOOLS_INDEX (ch_bam)
    ch_indexes = SAMTOOLS_INDEX.out.index
    ch_bam
    .join (ch_indexes)
    .set { ch_indexed_bam }
    emit: ch_indexed_bam
}


workflow {
    if (!params.indexed) {
        index()
        ch_indexed_bam = index.out
        emit: ch_indexed_bam
    }
    else if (params.indexed) {
        Channel.fromPath(params.input)
            .splitCsv(header:true, sep:',')
            .map { row -> [ ["id" : row.id], file(row.bam, checkIfExists: true), file(row.bam + ".*ai", checkIfExists: true) ] }
            .set { ch_indexed_bam }
    }
    SAMTOFASTQ (
        ch_indexed_bam,
        file(params.fasta)
    )

    emit: ch_indexed_bam.view()


    // ch_bam.view()
}