using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class levelFinish : MonoBehaviour
{
    public GameObject player;
    public GameObject text;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    void OnTriggerEnter(Collider other) {
        text.GetComponent<Text>().color = new Color(0, 0, 0, 1);
    }
}
