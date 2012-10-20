#!/usr/bin/pyhon
import os, sys

class Join:
	def fetch(self, in_file, key_idx, delimiter=","):
		result = {}
		f = open(in_file, "r")
		for line in f:
			tokens = line.strip().split(delimiter)
			key = tokens[key_idx]
			tokens.pop(key_idx)
			value = tokens
			result[key] = value
		f.close()
		return result
	
	def run(self, in_file, tgt_file, src_key_idx, src_delimiter, tgt_key_idx, tgt_delimiter, out_delimiter=","):
		tgts = self.fetch(tgt_file, tgt_key_idx, tgt_delimiter)
		f = open(in_file, "r")
		for line in f:
			tokens = line.strip().split(src_delimiter)
			src_key = tokens[src_key_idx]
			if src_key not in tgts: continue
			tokens.extend(tgts[src_key])
			print out_delimiter.join(tokens)
		f.close()

if __name__ == "__main__":
	job = Join()
	if len(sys.argv) < 7:
		print "Usage: python Join.py [infile] [tgt file] [src_key_idx] [src_delimiter] [tgt_key_idx] [tgt_delimiter] [out_delimiter(optional)]"
	elif len(sys.argv) == 7:
		job.run(sys.argv[1], sys.argv[2], int(sys.argv[3]), sys.argv[4], int(sys.argv[5]), sys.argv[6])
	else: 
		job.run(sys.argv[1], sys.argv[2], int(sys.argv[3]), sys.argv[4], int(sys.argv[5]), sys.argv[6], sys.argv[7])
