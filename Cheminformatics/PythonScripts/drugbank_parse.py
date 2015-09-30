__author__ = 'abhikseal'

import os
import collections
import zipfile
import xml.etree.ElementTree as ET
import pandas

filepath = os.path.join('drugbank.xml.zip')

zfile = zipfile.ZipFile(filepath)

for finfo in zfile.infolist():
        ifile = zfile.open(finfo)
        tree = ET.parse(ifile)
root = tree.getroot()

ns = '{http://www.drugbank.ca}'
inchikey_template = "{ns}calculated-properties/{ns}property[{ns}kind='InChIKey']/{ns}value"
inchi_template = "{ns}calculated-properties/{ns}property[{ns}kind='InChI']/{ns}value"

def collapse_list_values(row):
    for key, value in row.items():
        if isinstance(value, list):
            row[key] = '|'.join(value)
    return row


rows = list()
for i, drug in enumerate(root):
    row = collections.OrderedDict()
    assert drug.tag == ns + 'drug'
    row['type'] = drug.get('type')
    row['drugbank_id'] = drug.findtext(ns + "drugbank-id[@primary='true']")
    row['name'] = drug.findtext(ns + "name")
    row['groups'] = [group.text for group in
        drug.findall("{ns}groups/{ns}group".format(ns = ns))]
    row['atc_codes'] = [code.get('code') for code in
        drug.findall("{ns}atc-codes/{ns}atc-code".format(ns = ns))]
    row['categories'] = [x.findtext(ns + 'category') for x in
        drug.findall("{ns}categories/{ns}category".format(ns = ns))]
    row['inchi'] = drug.findtext(inchi_template.format(ns = ns))
    row['inchikey'] = drug.findtext(inchikey_template.format(ns = ns))
    rows.append(row)



rows = list(map(collapse_list_values, rows))
columns = ['drugbank_id', 'name', 'type', 'groups', 'atc_codes', 'categories', 'inchikey', 'inchi']
drugbank_df = pandas.DataFrame.from_dict(rows)[columns]

print (drugbank_df.head())


protein_rows = list()
for i, drug in enumerate(root):
    drugbank_id = drug.findtext(ns + "drugbank-id[@primary='true']")
    for category in ['target', 'enzyme', 'carrier', 'transporter']:
        proteins = drug.findall('{ns}{cat}s/{ns}{cat}'.format(ns=ns, cat=category))
        for protein in proteins:
            row = {'drugbank_id': drugbank_id, 'category': category}
            row['organism'] = protein.findtext('{}organism'.format(ns))
            row['known_action'] = protein.findtext('{}known-action'.format(ns))
            actions = protein.findall('{ns}actions/{ns}action'.format(ns=ns))
            row['actions'] = '|'.join(action.text for action in actions)
            uniprot_ids = [polypep.text for polypep in protein.findall(
                "{ns}polypeptide/{ns}external-identifiers/{ns}external-identifier[{ns}resource='UniProtKB']/{ns}identifier".format(ns=ns))]
            if len(uniprot_ids) != 1:
                continue
            row['uniprot_id'] = uniprot_ids[0]
            protein_rows.append(row)

protein_df = pandas.DataFrame.from_dict(protein_rows)
print (protein_df.head())