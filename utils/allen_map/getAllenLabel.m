function abbv=getAllenLabel(labelTable, id)
rows=labelTable.id==id;
abbv=labelTable{rows,{'abbreviation'}};
end