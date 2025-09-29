from sklearn.metrics import f1_score,recall_score,precision_score,accuracy_score,confusion_matrix
import paired

def do_tokenize(text):
    text=text.replace(">","> ")
    text=text.replace("<"," <")
    tokens=text.split()
    return tokens

def xml_to_bin(xml,tag_name):
    
    tokens=do_tokenize(xml)

    y_bin=[]
    y_bin_ref=[]

    tag_switch=0
    start_tag=f"<{tag_name}>"
    end_tag=f"</{tag_name}>"

    for token in tokens:
        if(start_tag in token):
            tag_switch=1
            continue
        if(end_tag in token):
            tag_switch=0
            continue
        y_bin.append(tag_switch)
        y_bin_ref.append(token)

    return y_bin,y_bin_ref

def do_praf(xml_true,xml_pred,tag_name):
    praf={}
    true_bin,true_bin_ref=xml_to_bin(xml_true,tag_name)
    pred_bin,pred_bin_ref=xml_to_bin(xml_pred,tag_name)

    pair_aligned=paired.align(true_bin_ref, pred_bin_ref)
    true_bin_aligned=[]
    pred_bin_aligned=[]
    true_bin_ref_aligned=[]
    pred_bin_ref_aligned=[]

    for true_i, pred_i in pair_aligned:
        if(true_i==None):
            true_bin_aligned.append(0)
            true_bin_ref_aligned.append("[NOM]")
        else:
            true_bin_aligned.append(true_bin[true_i])
            true_bin_ref_aligned.append(true_bin_ref[true_i])
        if(pred_i==None):
            pred_bin_aligned.append(0)
            pred_bin_ref_aligned.append("[NOM]")
        else:
            pred_bin_aligned.append(pred_bin[pred_i])
            pred_bin_ref_aligned.append(pred_bin_ref[pred_i])

    praf["true_pred_disp"]=len(true_bin)-len(pred_bin)
    praf["true_align_disp"]=len(true_bin)-len(true_bin_aligned)

    praf["precision"]=precision_score(true_bin_aligned,pred_bin_aligned,average="macro")
    praf["recall"]=recall_score(true_bin_aligned,pred_bin_aligned,average="macro")
    praf["accuracy"]=accuracy_score(true_bin_aligned,pred_bin_aligned)
    praf["f1"]=f1_score(true_bin_aligned,pred_bin_aligned,average="macro")
    praf["confusion_matrix"]=confusion_matrix(true_bin_aligned,pred_bin_aligned,labels=[0,1])

    praf["y_true"]=true_bin_aligned
    praf["y_pred"]=pred_bin_aligned

    praf["y_true_token"]=true_bin_ref_aligned
    praf["y_pred_token"]=pred_bin_ref_aligned

    return praf
