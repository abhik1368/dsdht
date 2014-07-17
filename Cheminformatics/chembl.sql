set rdkit.morgan_fp_size=1024 ;

create table tmp_data as 
SELECT DISTINCT molecule_dictionary.chembl_id,compound_structures.canonical_smiles,ASSAYS.TID,target_dictionary.chembl_id AS target_chembl_id,
TARGET_DICTIONARY.ORGANISM,ACTIVITIES.*,assays.chembl_id AS assay_chembl_id 
from molecule_dictionary,compound_structures,assays,activities,target_dictionary 
where compound_structures.molregno = MOLECULE_DICTIONARY.MOLREGNO 
and MOLECULE_DICTIONARY.MOLREGNO = ACTIVITIES.MOLREGNO 
and ASSAYS.TID = TARGET_DICTIONARY.TID AND ASSAYS.ASSAY_ID = ACTIVITIES.ASSAY_ID 
and ACTIVITIES.STANDARD_UNITS = 'nM' AND ACTIVITIES.STANDARD_VALUE < 50 
and TARGET_DICTIONARY.ORGANISM = 'Homo sapiens' 
order by activities.standard_value ;


select chembl_id,target_chembl_id,standard_value,published_type,data_validity_comment ,morganbv_fp(canonical_smiles::mol,4) as 
ecfp4 into rdkfps_1 from tmp_data where is_valid_smiles(canonical_smiles::cstring) ;  

#Count number of targets 
select count(distinct target_chembl_id) as tid from rdkfps_1 ;

#count number of molecules
select count(distinct chembl_id) as tid from rdkfps_1 ;

#count number of molecules of a specific target
select count(*)  from rdkfps_1 where target_chembl_id ='CHEMBL224' ;
