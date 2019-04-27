function inject_template(template_path, values, out_path)
    template = fileread(template_path);
    
    fields = fieldnames(values);
    for i = 1:numel(fields)
        field = fields{i};
        value = values.(field);
        
        if isnumeric(value)
           value =  num2str(value);
        end
        
        template = strrep(template, "{{"+field+"}}", value);
    end
        
    note = "% DO NOT CHANGE THIS FILE, IT IS AUTO GENERATED FROM THE TEMPLATE '"+template_path+"'";
    f = fopen(out_path, 'w');
    fprintf(f, '%s\n\n%s', note, template);
    fclose(f);
end

