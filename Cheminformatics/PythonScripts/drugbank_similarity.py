__author__ = 'abhikseal'

import itertools
import gzip

import pandas
import rdkit.Chem
import rdkit.Chem.AllChem
import rdkit.DataStructs


s = rdkit.Chem.SDMolSupplier('data/all.sdf')
molecules = [mol for mol in supplier if mol is not None]
print len(molecules)