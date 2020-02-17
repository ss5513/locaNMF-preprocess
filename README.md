# LocaNMF-preprocess

Preprocesses calcium imaging data to use with [LocaNMF](https://github.com/ikinsella/locaNMF). Read more about this method and the results it provides in our bioRxiv : [Saxena et al., 2019](https://www.biorxiv.org/content/10.1101/650093v1)!

Instructions:

1) Save your data as a .mat file with calcium imaging video as variable 'Y', with dimensions pixels x pixels x time.

2) Find an atlas of regions that segments the field of view into separate regions. For widefield calcium imaging data in the mouse dorsal cortex, use the atlas.mat provided in 'utils', which is based off of the Allen atlas, as in [Musall et al., 2019](https://www.nature.com/articles/s41593-019-0502-4).

3) Run process_dataset.m in MATLAB to (a) define a brainmask, (b) denoise the dataset, (c) align the atlas to the dataset.

4) Run [LocaNMF](https://github.com/ikinsella/locaNMF)!
