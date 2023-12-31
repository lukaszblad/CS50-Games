using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Text))]
public class MazeText : MonoBehaviour
{
    public GameObject player;
    private int mazeNumber;
    private Text text;
    public static int levelCounter = 1;

    // Start is called before the first frame update
    void Start()
    {
        text = GetComponent<Text>();
    }

    // Update is called once per frame
    void Update()
    {
        text.text = "Level: " + levelCounter;
    }
}
