function expected = expectedContingencyTable(contingencyTable)
marginals_row = sum(contingencyTable,2) / sum(contingencyTable(:));
marginals_col = sum(contingencyTable,1) / sum(contingencyTable(:));

expected = (marginals_row * marginals_col) * sum(contingencyTable(:));
end