#!/usr/bin/env npx ts-node

/**
 * Formats a raw brain dump transcript into one sentence per line.
 * This is a deterministic preprocessing step before LLM extraction.
 *
 * Usage: npx ts-node format-raw-dump.ts <path-to-raw-dump.txt>
 * Output: raw-dump-formatted.txt in the same directory
 */

import { readFileSync, writeFileSync } from "fs"
import { dirname, join } from "path"

function formatRawDump(inputPath: string): void {
	const content = readFileSync(inputPath, "utf-8")

	// Normalize whitespace: collapse multiple spaces/newlines into single space
	let normalized = content
		.replace(/\r\n/g, " ")
		.replace(/\n/g, " ")
		.replace(/\s+/g, " ")
		.trim()

	// Common abbreviations that shouldn't end sentences
	const abbreviations = [
		"Mr",
		"Mrs",
		"Ms",
		"Dr",
		"Prof",
		"Sr",
		"Jr",
		"vs",
		"etc",
		"e.g",
		"i.e",
		"a.m",
		"p.m",
		"U.S",
		"Inc",
		"Ltd",
		"Corp",
		"St",
		"Ave",
		"Blvd",
	]

	// Protect abbreviations by replacing their periods temporarily
	for (const abbr of abbreviations) {
		const pattern = new RegExp(`\\b${abbr}\\.`, "gi")
		normalized = normalized.replace(pattern, `${abbr}<<ABBR>>`)
	}

	// Protect decimal numbers (e.g., "3.5", "$500.00")
	normalized = normalized.replace(/(\d)\.(\d)/g, "$1<<DECIMAL>>$2")

	// Protect ellipsis
	normalized = normalized.replace(/\.{3}/g, "<<ELLIPSIS>>")
	normalized = normalized.replace(/…/g, "<<ELLIPSIS>>")

	// Split on sentence-ending punctuation followed by space and capital letter or end
	// Handles: . ! ?
	const sentences: string[] = []
	let buffer = ""

	const tokens = normalized.split(/([.!?]+\s*)/)

	for (let i = 0; i < tokens.length; i++) {
		buffer += tokens[i]

		// Check if this token is sentence-ending punctuation
		if (/^[.!?]+\s*$/.test(tokens[i])) {
			// Look ahead to see if next token starts with capital or is end
			const nextToken = tokens[i + 1]
			if (!nextToken || /^[A-Z]/.test(nextToken.trim())) {
				// End of sentence
				const sentence = buffer
					.replace(/<<ABBR>>/g, ".")
					.replace(/<<DECIMAL>>/g, ".")
					.replace(/<<ELLIPSIS>>/g, "...")
					.trim()

				if (sentence.length > 0) {
					sentences.push(sentence)
				}
				buffer = ""
			}
		}
	}

	// Don't forget any remaining buffer
	if (buffer.trim().length > 0) {
		const sentence = buffer
			.replace(/<<ABBR>>/g, ".")
			.replace(/<<DECIMAL>>/g, ".")
			.replace(/<<ELLIPSIS>>/g, "...")
			.trim()

		sentences.push(sentence)
	}

	// Write output
	const outputPath = join(dirname(inputPath), "raw-dump-formatted.txt")
	const output = sentences.join("\n")

	writeFileSync(outputPath, output, "utf-8")

	console.log(`Formatted ${sentences.length} sentences`)
	console.log(`Output: ${outputPath}`)
}

// CLI
const args = process.argv.slice(2)
if (args.length !== 1) {
	console.error("Usage: npx ts-node format-raw-dump.ts <path-to-raw-dump.txt>")
	process.exit(1)
}

formatRawDump(args[0])
