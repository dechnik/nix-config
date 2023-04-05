pkgs:
let
  programs = with pkgs; [
    gnugrep
    gnused
    pandoc
  ];

  convert-multipart = pkgs.writeShellScript "convert-multipart" ''
    export PATH=$PATH:${pkgs.lib.makeBinPath programs}

    commandsFile="/tmp/neomutt-commands"
    markdownFile="/tmp/neomutt-markdown"
    htmlFile="/tmp/neomutt.html"

    cat - > "$markdownFile.orig"
    echo -n "push " > "$commandsFile"

    cp "$markdownFile.orig" "$markdownFile"

    grep -Eo '!\[[^]]*\]\([^)]+' "$markdownFile" | cut -d '(' -f 2 |
    	grep -Ev '^(cid:|https?://)' | while read file; do
    		id="cid:$(md5sum "$file" | cut -d ' ' -f 1 )"
    		sed -i "s#$file#$id#g" "$markdownFile"
    	done

    if [ "$(grep -Eo '!\[[^]]*\]\([^)]+' "$markdownFile" | cut -d '(' -f 2  | grep '^cid:' | wc -l)" -gt 0 ]; then
    	echo -n "<attach-file>\"$markdownFile\"<enter><toggle-disposition><toggle-unlink><first-entry><detach-file>" >> "$commandsFile"
    fi

    pandoc -f markdown -t html5 --standalone --template ~/.local/share/mail/.templates/email2.html "$markdownFile" > "$htmlFile"

    # Attach the html file
    echo -n "<attach-file>\"$htmlFile\"<enter>" >> "$commandsFile"

    # Set it as inline
    echo -n "<toggle-disposition>" >> "$commandsFile"

    # Tell neomutt to delete it after sending
    echo -n "<toggle-unlink>" >> "$commandsFile"

    # Select both the html and markdown files
    echo -n "<tag-entry><previous-entry><tag-entry>" >> "$commandsFile"

    # Group the selected messages as alternatives
    echo -n "<group-alternatives>" >> "$commandsFile"

    grep -Eo '!\[[^]]*\]\([^)]+' "$markdownFile.orig" | cut -d '(' -f 2 |
    	grep -Ev '^(cid:|https?://)' | while read file; do
    	id="$(md5sum "$file" | cut -d ' ' -f 1 )"
    	echo -n "<attach-file>\"$file\"<enter>" >> "$commandsFile"
    	echo -n "<toggle-disposition>" >> "$commandsFile"
    	echo -n "<edit-content-id>^u\"$id\"<enter>" >> "$commandsFile"
    	echo -n "<tag-entry>" >> "$commandsFile"
    done


    if [ "$(grep -Eo '!\[[^]]*\]\([^)]+' "$markdownFile" | cut -d '(' -f 2 | grep '^cid:' |
    	wc -l)" -gt 0 ]; then
    	echo -n "<first-entry><tag-entry><group-related>" >> "$commandsFile"
    fi
  '';
in
convert-multipart
