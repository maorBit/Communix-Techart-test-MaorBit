using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;
using UnityEngine.UI;

public class PopUpManager : MonoBehaviour
{
    public float fadeTime = 1f;
    public GameObject elementsHolder;
    public GameObject[] Elements;
    public RectTransform rectTransform;
    public CanvasGroup canvasGroup;
    public RectTransform body;

    [Header("particles")]
    public GameObject RevealParticles;
    public GameObject LoopParticles;
    public GameObject BearParticles;

    [Header("Eases")]
    public Ease E_mainPanel;
    public Ease E_elements;
    public Ease E_Idle;

    //void Start()
    //{
    //    HideElements();
    //    PanelFadeIn();
    //}

    private void OnEnable()
    {
        HideElements();
        PanelFadeIn();
    }
    public void HideElements()
    {
        RevealParticles.SetActive(false);
        LoopParticles.SetActive(false);
        BearParticles.SetActive(false);

        elementsHolder.GetComponent<RectTransform>().localScale = Vector2.zero;
        elementsHolder.SetActive(false);

        foreach (var element in Elements)
        {
            element.GetComponent<RectTransform>().localScale = Vector2.zero;
            element.SetActive(false);
        }
    }
    public void PanelFadeIn()
    {
        canvasGroup.alpha = 0f;
        rectTransform.transform.localPosition = new Vector3(0f, -2000f, 0f);
        rectTransform.DOAnchorPos(new Vector2(0f, 0f), 1, false).SetEase(E_mainPanel);
        canvasGroup.DOFade(1, fadeTime).OnComplete(() =>
        {
            RevealElements();
        }); ;
    }

    public void RevealElements()
    {
        RevealParticles.SetActive(true);
        elementsHolder.SetActive(true);
        elementsHolder.GetComponent<RectTransform>().DOScale(new Vector2(1, 1), 0.5f).SetEase(E_mainPanel);
        var sequence = DOTween.Sequence();
        foreach (var element in Elements)
        {
            element.SetActive(true);
            LayoutRebuilder.ForceRebuildLayoutImmediate(body);
            sequence.Append(element.GetComponent<RectTransform>().DOScale(new Vector2(1, 1), 0.5f).SetEase(E_elements));
        }

        sequence.OnStepComplete(SetIdleAnimation);
        
    }

    public void SetIdleAnimation()
    {
        LoopParticles.SetActive(true);
        BearParticles.SetActive(true);

        rectTransform.DOAnchorPos(new Vector2(0f, 30f), 2f, false).SetEase(E_Idle).SetLoops(4, LoopType.Yoyo).OnComplete(() =>
        {
            rectTransform.DOAnchorPos(new Vector2(0f, -2000f), 0.5f, false).SetEase(E_mainPanel);
            canvasGroup.DOFade(0, fadeTime);

            RevealParticles.SetActive(false);
            LoopParticles.SetActive(false);
            BearParticles.SetActive(false);
        });
    }
}
