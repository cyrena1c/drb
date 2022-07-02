drb: drb.sh drb.txt drb_aliases.txt print_chapter.awk
	cat drb.sh > $@
	echo 'exit 0' >> $@
	echo '#EOF' >> $@
	tar czf - drb_aliases.txt print_chapter.awk drb.txt >> $@
	chmod +x $@

drb.txt: pg1581.txt edits.ed
	dos2unix -n pg1581.txt drb.txt
	cat edits.ed | ed drb.txt

lint: drb.sh
	shellcheck -s sh drb.sh

clean:
	-rm -vf drb.txt
	-rm -vf drb

.PHONY: lint clean
